//
//  UserAgent.swift
//  UserAgent
//
//  The namespace: one string in, a typed client out.
//

import Foundation

/// Browser, engine, operating system, device class and crawler identity from a
/// `User-Agent` string — honest about what the string cannot say.
///
/// User agents lie, and have since Netscape claimed to be Mozilla. Everything
/// here is a heuristic: fine for analytics, segmentation and deciding whether
/// to count a hit, and not fine as a security boundary. Nothing this package
/// returns should gate access to anything.
///
/// The parse never throws. A string it does not recognise comes back as a
/// ``Client`` with nil parts and ``DeviceClass/unknown``, because the caller
/// asked a question about a request and "I don't know" is a valid answer.
public enum UserAgent {

    /// The longest string that is read. Nothing legitimate is longer, and the
    /// value ends up in log rows and database columns.
    public static let maximumLength = 512

    /// Reads one `User-Agent` string.
    ///
    /// Patterns are tried most-specific first, because the tokens nest: an
    /// Edge string contains `Chrome`, a Chrome string contains `Safari`, and
    /// only the order keeps them apart. The string is capped at
    /// ``maximumLength`` before anything looks at it.
    ///
    /// - Parameter additionalBots: crawlers of your own to recognise first,
    ///   matched as case-insensitive substrings of ``Bot/name``. The built-in
    ///   list tracks ai.robots.txt and goes stale like every such list.
    public static func parse(_ string: String, additionalBots: [Bot] = []) -> Client {
        ClientParsing.parse(string, additionalBots: additionalBots)
    }

    /// A well-formed outgoing `User-Agent` for your own requests.
    ///
    /// `product/version (+contact)` is the shape crawlers have used for twenty
    /// years, and the shape an operator reading their logs can act on. Spaces
    /// in the product name become hyphens because the product is a token; a
    /// bare email address is prefixed with `mailto:` so the parentheses hold a
    /// URL either way.
    ///
    /// ```swift
    /// UserAgent.string(product: "MetricBar", version: "1.4", contact: "https://metricbar.app")
    /// // "MetricBar/1.4 (+https://metricbar.app)"
    /// ```
    public static func string(product: String, version: String, contact: String? = nil) -> String {
        UserAgentBuilding.string(product: product, version: version, contact: contact)
    }
}
