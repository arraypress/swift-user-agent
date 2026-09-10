//
//  Client+Facts.swift
//  UserAgent
//
//  The questions people actually ask of a client, as one-liners.
//

import Foundation

extension Client {

    /// Whether this is a crawler, scraper or programmatic client.
    ///
    /// An empty string counts: an absent user agent is not a browser, and a
    /// request without one is almost always a script.
    public var isBot: Bool {
        bot != nil || raw.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Whether this is an AI or LLM crawler of either kind — training
    /// corpus or on a person's behalf. Separated from ``isBot`` because the
    /// decision about them is usually different from the one about Googlebot.
    public var isAI: Bool {
        bot.map { $0.category == .ai || $0.category == .aiUser } ?? false
    }

    /// Whether this is an assistant fetching a page because a person asked
    /// for it. Refusing it is refusing a visitor; see ``BotCategory/aiUser``.
    public var isAIUserFetch: Bool {
        bot?.category == .aiUser
    }

    /// Whether the device is a phone or a tablet.
    public var isMobile: Bool {
        device == .phone || device == .tablet
    }

    /// A short readable line: `Chrome 131 on macOS`, `Googlebot`,
    /// `Instagram on iOS`, or `Unknown`.
    public var describe: String {
        Describing.describe(self)
    }
}
