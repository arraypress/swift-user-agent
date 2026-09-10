//
//  Client.swift
//  UserAgent
//

import Foundation

/// Everything one `User-Agent` string says about the thing that sent it.
///
/// Each part is independent and each can be missing. A crawler has a
/// ``bot`` and usually no ``browser``; an in-app browser has a ``webview``
/// and often a ``browser`` too; an empty string has none of them and a
/// ``device`` of ``DeviceClass/unknown``.
public struct Client: Sendable, Hashable, Codable {

    /// The string as read, capped at ``UserAgent/maximumLength``.
    public let raw: String

    /// The browser, when one is recognised.
    public let browser: Browser?

    /// The rendering engine, inferred from the tokens rather than the brand —
    /// which is why every browser on iOS reports WebKit.
    public let engine: Engine

    /// The operating system, when one is recognised.
    public let os: OperatingSystem?

    /// Phone, tablet, desktop, bot, or unknown.
    public let device: DeviceClass

    /// The crawler, scraper or programmatic client, when it is one.
    public let bot: Bot?

    /// The in-app or embedded browser hosting the page, when there is one.
    public let webview: Webview?

    /// Builds a client by hand; ``UserAgent/parse(_:additionalBots:)`` is the usual source.
    public init(
        raw: String,
        browser: Browser?,
        engine: Engine,
        os: OperatingSystem?,
        device: DeviceClass,
        bot: Bot?,
        webview: Webview?
    ) {
        self.raw = raw
        self.browser = browser
        self.engine = engine
        self.os = os
        self.device = device
        self.bot = bot
        self.webview = webview
    }
}
