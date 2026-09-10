//
//  BotCategory.swift
//  UserAgent
//

import Foundation

/// What kind of automated client this is — the part that decides what to do
/// about it.
///
/// The split most lists miss is ``ai`` against ``aiUser``. Several operators
/// run separate tokens for crawling a training corpus and for fetching a
/// page a person just asked about: GPTBot and ChatGPT-User, PerplexityBot
/// and Perplexity-User, ClaudeBot and Claude-User. Blocking the first is a
/// licensing decision; blocking the second means a person asked to see your
/// page and got an error.
public enum BotCategory: String, Sendable, Hashable, Codable, CaseIterable {

    /// A search engine's indexer: Googlebot, bingbot, Applebot.
    case search

    /// An AI or LLM crawler building or refreshing a corpus.
    case ai

    /// An AI assistant fetching a page because a person asked for it.
    case aiUser

    /// A social network's link unfurler.
    case social

    /// An SEO or backlink crawler.
    case seo

    /// An uptime or performance monitor.
    case monitoring

    /// A programmatic HTTP client: curl, wget, python-requests, okhttp.
    case programmatic

    /// Recognised only by a word like `bot`, `spider` or `crawler`.
    case generic
}
