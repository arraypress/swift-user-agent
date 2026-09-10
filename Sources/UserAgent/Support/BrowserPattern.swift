//
//  BrowserPattern.swift
//  UserAgent
//
//  The browser table. Order is the algorithm.
//

import Foundation

/// One row of the browser table: the tokens that identify a browser and
/// where its version follows.
///
/// Order matters more than the patterns do. Chrome's string contains
/// `Safari`, Edge's contains `Chrome`, Samsung Internet's contains both —
/// so the branded rows come first and the generic `Chrome` and `Safari`
/// rows are tried last, needing no exclusion lists at all.
struct BrowserPattern: Sendable {

    /// The product name reported in ``Browser/name``.
    let name: String

    /// The engine this browser runs on, before the iOS override in
    /// ``ClientParsing/engine(in:os:)``.
    let engine: Engine

    /// Any one of these must appear (case-sensitive).
    let tokens: [String]

    /// All of these must appear too.
    let requires: [String]

    /// None of these may appear.
    let excludes: [String]

    /// Where the version follows, tried in order. Nil means "after the token
    /// that matched", which is right for `Chrome/131`.
    let versionTokens: [String]?

    init(
        _ name: String,
        engine: Engine,
        tokens: [String],
        requires: [String] = [],
        excludes: [String] = [],
        versionTokens: [String]? = nil
    ) {
        self.name = name
        self.engine = engine
        self.tokens = tokens
        self.requires = requires
        self.excludes = excludes
        self.versionTokens = versionTokens
    }

    /// The table, most specific first.
    static let all: [BrowserPattern] = [
        // Branded Chromium builds, each with its own token, before Chrome.
        BrowserPattern("Edge", engine: .blink, tokens: ["Edg/", "EdgA/", "EdgiOS/", "Edge/"]),
        // Opera Mini first: its string also says "Opera/9.80", which is the
        // Presto engine's number and never changed.
        BrowserPattern("Opera Mini", engine: .presto, tokens: ["Opera Mini/"]),
        BrowserPattern("Opera", engine: .blink, tokens: ["OPR/", "Opera/"], versionTokens: ["OPR/", "Version/", "Opera/"]),
        BrowserPattern("Brave", engine: .blink, tokens: ["Brave/"]),
        BrowserPattern("Vivaldi", engine: .blink, tokens: ["Vivaldi/"]),
        BrowserPattern("Samsung Internet", engine: .blink, tokens: ["SamsungBrowser/"]),
        BrowserPattern("UC Browser", engine: .blink, tokens: ["UCBrowser/"]),
        BrowserPattern("DuckDuckGo", engine: .webkit, tokens: ["DuckDuckGo/"]),

        // iOS shells over WebKit, before the desktop browsers they are named after.
        BrowserPattern("Chrome iOS", engine: .webkit, tokens: ["CriOS/"]),
        BrowserPattern("Firefox iOS", engine: .webkit, tokens: ["FxiOS/"]),

        // Internet Explorer: 11 dropped the MSIE token and hid the version in rv:.
        BrowserPattern("Internet Explorer", engine: .trident, tokens: ["MSIE ", "Trident/"], versionTokens: ["MSIE ", "rv:"]),

        BrowserPattern("Firefox", engine: .gecko, tokens: ["Firefox/"], excludes: ["Seamonkey"]),

        // Generic, and therefore last. The Mobile token splits Chrome; the
        // iPhone/iPad/iPod tokens split Safari.
        BrowserPattern("Chrome Mobile", engine: .blink, tokens: ["Chrome/"], requires: ["Mobile"]),
        BrowserPattern("Chrome", engine: .blink, tokens: ["Chrome/", "Chromium/"]),
        BrowserPattern("Safari Mobile", engine: .webkit, tokens: ["iPhone", "iPad", "iPod"], requires: ["Version/", "Safari"], versionTokens: ["Version/"]),
        BrowserPattern("Safari", engine: .webkit, tokens: ["Safari"], requires: ["Version/"], excludes: ["Chrome", "Chromium"], versionTokens: ["Version/"]),
    ]
}
