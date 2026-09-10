//
//  Scanning.swift
//  UserAgent
//
//  The string primitives every table is matched with — plain scans, no regex.
//

import Foundation

/// Substring, word and version scans over a user-agent string.
///
/// Plain scanning rather than regular expressions because every pattern in
/// this package is a token followed by a number, and a token is a substring.
/// It is also what makes the tables readable: `Chrome/` says more than
/// `Chrome\/([0-9.]+)`.
enum Scanning {

    /// Whether any of `tokens` appears, case-sensitively.
    ///
    /// Case-sensitive because the tokens are: `Mobile` is Chrome's phone
    /// marker and `mobile` is a word in a URL.
    static func containsAny(_ tokens: [String], in text: String) -> Bool {
        tokens.contains { text.contains($0) }
    }

    /// The first of `tokens` that appears, in table order.
    static func firstToken(of tokens: [String], in text: String) -> String? {
        tokens.first { text.contains($0) }
    }

    /// Whether `token` appears, ignoring case — for crawler names, which
    /// their operators do not spell consistently.
    static func containsIgnoringCase(_ token: String, in text: String) -> Bool {
        text.range(of: token, options: .caseInsensitive) != nil
    }

    /// The version digits that follow `token`: `Chrome/131.0.0.0 Safari` reads
    /// `131.0.0.0`, and `iPhone OS 17_6 like` reads `17.6`, because Apple
    /// writes dots as underscores there.
    static func version(after token: String, in text: String) -> String? {
        guard let range = text.range(of: token) else { return nil }
        let digits = text[range.upperBound...].prefix { $0.isNumber || $0 == "." || $0 == "_" }
        let cleaned = digits
            .replacingOccurrences(of: "_", with: ".")
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return cleaned.isEmpty ? nil : cleaned
    }

    /// The first component of a dotted version as a number.
    static func major(of version: String?) -> Int? {
        guard let version, let first = version.split(separator: ".").first else { return nil }
        return Int(first)
    }

    /// The token containing `word` as a whole word, ignoring case, or nil.
    ///
    /// A substring match on `bot` is what produces the classic false
    /// positive: **Cubot** is a real Android phone brand, so every Cubot
    /// owner gets logged as a crawler, and `Abbott` fares no better. A word
    /// is bounded by anything that is not a letter or digit, which keeps
    /// `Foo bot/1.0` and `Foo-Bot` while releasing `Cubot_NOTE_20`.
    ///
    /// Returns the run of token characters around the word — `SomeNew Bot/1.0`
    /// gives `Bot`, `curl/8.7.1` gives `curl` — so a generic crawler still has
    /// a name.
    static func wordToken(_ word: String, in text: String) -> String? {
        let lower = text.lowercased()
        let target = word.lowercased()
        var searchFrom = lower.startIndex
        while let found = lower.range(of: target, range: searchFrom..<lower.endIndex) {
            let openBefore = found.lowerBound == lower.startIndex
                || !isWordCharacter(lower[lower.index(before: found.lowerBound)])
            let openAfter = found.upperBound == lower.endIndex
                || !isWordCharacter(lower[found.upperBound])
            if openBefore && openAfter {
                return expandedToken(around: found, in: text, lowered: lower)
            }
            searchFrom = found.upperBound
        }
        return nil
    }

    /// Letters and digits bind a word; everything else — space, slash,
    /// hyphen, underscore, bracket — ends one.
    private static func isWordCharacter(_ character: Character) -> Bool {
        character.isLetter || character.isNumber
    }

    /// Grows a match outward over token characters (letters, digits, `-`, `_`)
    /// and returns that slice of the original, case preserved.
    private static func expandedToken(
        around match: Range<String.Index>,
        in text: String,
        lowered: String
    ) -> String {
        func isTokenCharacter(_ character: Character) -> Bool {
            character.isLetter || character.isNumber || character == "-" || character == "_"
        }
        var start = match.lowerBound
        while start > lowered.startIndex, isTokenCharacter(lowered[lowered.index(before: start)]) {
            start = lowered.index(before: start)
        }
        var end = match.upperBound
        while end < lowered.endIndex, isTokenCharacter(lowered[end]) {
            end = lowered.index(after: end)
        }
        let offsetStart = lowered.distance(from: lowered.startIndex, to: start)
        let offsetEnd = lowered.distance(from: lowered.startIndex, to: end)
        let originalStart = text.index(text.startIndex, offsetBy: offsetStart)
        let originalEnd = text.index(text.startIndex, offsetBy: offsetEnd)
        return String(text[originalStart..<originalEnd])
    }
}
