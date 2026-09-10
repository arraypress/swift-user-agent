//
//  Bot.swift
//  UserAgent
//

import Foundation

/// A crawler, scraper or programmatic client, and which kind.
///
/// The kind is the useful part. Blocking a search engine is a visibility
/// decision, blocking a training crawler is a licensing decision, and
/// blocking ``BotCategory/aiUser`` means refusing a person who asked an
/// assistant to read your page.
public struct Bot: Sendable, Hashable, Codable {

    /// The crawler's own name as it appears in the string, e.g. `Googlebot`,
    /// `ClaudeBot`, `curl`. For an unnamed crawler recognised only by a word
    /// like `spider`, the token that word appeared in.
    public let name: String

    /// What kind of client this is.
    public let category: BotCategory

    /// Names a crawler — also how a caller declares its own for ``UserAgent/parse(_:additionalBots:)``.
    public init(name: String, category: BotCategory) {
        self.name = name
        self.category = category
    }
}
