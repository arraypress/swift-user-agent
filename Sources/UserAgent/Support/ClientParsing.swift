//
//  ClientParsing.swift
//  UserAgent
//
//  The parse, one part at a time, each a pure function over the string.
//

import Foundation

/// Assembles a ``Client`` from a user-agent string.
///
/// Every step is a function of the string alone, so each can be tested on
/// its own and none can disagree with another about what it read.
enum ClientParsing {

    /// The whole parse. Caps the string first, then reads each part.
    static func parse(_ string: String, additionalBots: [Bot]) -> Client {
        let raw = String(string.prefix(UserAgent.maximumLength))
        let bot = bot(in: raw, additional: additionalBots)
        let os = os(in: raw)
        let browser = browser(in: raw)
        return Client(
            raw: raw,
            browser: browser,
            engine: engine(in: raw, os: os),
            os: os,
            device: device(in: raw, isBot: bot != nil),
            bot: bot,
            webview: webview(in: raw, os: os)
        )
    }

    /// The first browser row whose tokens all hold.
    static func browser(in text: String) -> Browser? {
        for pattern in BrowserPattern.all {
            guard let matched = Scanning.firstToken(of: pattern.tokens, in: text),
                  pattern.requires.allSatisfy({ text.contains($0) }),
                  !Scanning.containsAny(pattern.excludes, in: text) else { continue }
            let version = (pattern.versionTokens ?? [matched])
                .lazy
                .compactMap { Scanning.version(after: $0, in: text) }
                .first
            return Browser(name: pattern.name, version: version, majorVersion: Scanning.major(of: version))
        }
        return nil
    }

    /// The engine, from the engine tokens rather than the brand.
    ///
    /// On iOS and iPadOS every browser is WebKit: Apple requires it, so
    /// Chrome, Firefox and Edge there are shells and the `CriOS`, `FxiOS`
    /// and `EdgiOS` tokens sit next to `AppleWebKit`. That override comes
    /// first. Elsewhere, `Trident` is Internet Explorer, a dated `Gecko/`
    /// is Firefox (`like Gecko` is every WebKit string pretending),
    /// `Edge/` without a Chromium version is the original Edge, `Presto`
    /// is old Opera, `Chrome/` is Blink, and a bare `AppleWebKit` is WebKit.
    static func engine(in text: String, os: OperatingSystem?) -> Engine {
        if let os, os.name == "iOS" || os.name == "iPadOS" {
            return text.contains("AppleWebKit") ? .webkit : .unknown
        }
        if Scanning.containsAny(["Trident/", "MSIE "], in: text) { return .trident }
        if text.contains("Gecko/") { return .gecko }
        if text.contains("Presto/") || text.contains("Opera Mini/") { return .presto }
        if text.contains("Edge/") { return .edgeHTML }
        if Scanning.containsAny(["Chrome/", "Chromium/", "HeadlessChrome/"], in: text) { return .blink }
        if text.contains("AppleWebKit") { return .webkit }
        return .unknown
    }

    /// The first operating-system row whose tokens hold, with a frozen
    /// version dropped rather than repeated.
    static func os(in text: String) -> OperatingSystem? {
        for pattern in OSPattern.all {
            guard Scanning.containsAny(pattern.tokens, in: text),
                  !Scanning.containsAny(pattern.excludes, in: text) else { continue }
            let version = pattern.versionTokens
                .lazy
                .compactMap { Scanning.version(after: $0, in: text) }
                .first
            let liedAbout = version.map { found in
                pattern.frozenPrefixes.contains { found == $0 || found.hasPrefix($0 + ".") }
            } ?? false
            let frozen = pattern.isFrozen || liedAbout
            return OperatingSystem(name: pattern.name, version: frozen ? nil : version, isFrozen: frozen)
        }
        return nil
    }

    /// Phone, tablet, desktop, bot or unknown.
    ///
    /// An Android tablet is identified by the absence of `Mobile`, which is
    /// one of the less helpful decisions in the platform. An iPad asking for
    /// the desktop site sends a Mac string and lands on desktop; the string
    /// gives no way to do better.
    static func device(in text: String, isBot: Bool) -> DeviceClass {
        if text.trimmingCharacters(in: .whitespaces).isEmpty { return .unknown }
        if isBot { return .bot }
        if Scanning.containsAny(["iPad", "Tablet", "Kindle", "Silk", "PlayBook"], in: text) { return .tablet }
        if text.contains("Android"), !text.contains("Mobile") { return .tablet }
        if Scanning.containsAny(["iPhone", "iPod", "Windows Phone", "BlackBerry", "Opera Mini", "IEMobile"], in: text) { return .phone }
        if text.contains("Android"), text.contains("Mobile") { return .phone }
        return .desktop
    }

    /// A named crawler, then a generic one by word, then nothing.
    ///
    /// Callers' own entries go first so a private crawler can be filed under
    /// whatever category they choose before the built-in list has a say.
    static func bot(in text: String, additional: [Bot]) -> Bot? {
        for own in additional where Scanning.containsIgnoringCase(own.name, in: text) {
            return own
        }
        for entry in BotEntry.named where Scanning.containsIgnoringCase(entry.name, in: text) {
            return Bot(name: entry.name, category: entry.category)
        }
        for word in BotEntry.genericWords {
            if let token = Scanning.wordToken(word, in: text) {
                return Bot(name: token, category: .generic)
            }
        }
        for word in BotEntry.programmaticWords {
            if let token = Scanning.wordToken(word, in: text) {
                return Bot(name: token, category: .programmatic)
            }
        }
        return nil
    }

    /// The hosting web view, if any: a named application first, then the
    /// two bare system web views by their structure.
    ///
    /// Android's WebView is marked by a `wv` token, or on older releases by
    /// a `Version/4.0` that Chrome proper never sends — the pre-KitKat stock
    /// browser sent it too, and was the same engine. A `WKWebView` on iOS
    /// is WebKit without the `Version/` token Safari always carries and
    /// without the token of any iOS browser.
    static func webview(in text: String, os: OperatingSystem?) -> Webview? {
        for pattern in WebviewPattern.apps where Scanning.containsAny(pattern.tokens, in: text) {
            return pattern.webview
        }
        if text.contains("Android"),
           Scanning.wordToken("wv", in: text) != nil || text.contains("Version/") {
            return .androidWebView
        }
        if let os, os.name == "iOS" || os.name == "iPadOS",
           text.contains("AppleWebKit"),
           !text.contains("Version/"),
           !Scanning.containsAny(["CriOS/", "FxiOS/", "EdgiOS/", "OPiOS/", "DuckDuckGo/"], in: text) {
            return .iOSWebView
        }
        return nil
    }
}
