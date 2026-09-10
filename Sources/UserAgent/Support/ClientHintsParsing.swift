//
//  ClientHintsParsing.swift
//  UserAgent
//
//  Structured-header reading for the Sec-CH-UA family.
//

import Foundation

/// Reads the `Sec-CH-UA-*` headers into a ``ClientHints``.
///
/// Header names are matched ignoring case because every server framework
/// normalises them differently, and values are structured-header strings —
/// quoted, or `?1`/`?0` for booleans — so the quotes are stripped here and
/// nowhere else.
enum ClientHintsParsing {

    /// The headers this package reads, lowercased.
    static let names = [
        "sec-ch-ua", "sec-ch-ua-mobile", "sec-ch-ua-platform", "sec-ch-ua-platform-version",
        "sec-ch-ua-model", "sec-ch-ua-arch", "sec-ch-ua-full-version-list",
    ]

    /// The parse.
    static func parse(headers: [String: String]) -> ClientHints {
        let lowered = Dictionary(headers.map { ($0.key.lowercased(), $0.value) }, uniquingKeysWith: { first, _ in first })
        func value(_ name: String) -> String? {
            guard let raw = lowered[name] else { return nil }
            let unquoted = unquote(raw)
            return unquoted.isEmpty ? nil : unquoted
        }
        return ClientHints(
            brands: brands(from: lowered["sec-ch-ua"] ?? ""),
            fullVersions: brands(from: lowered["sec-ch-ua-full-version-list"] ?? ""),
            platform: value("sec-ch-ua-platform"),
            platformVersion: value("sec-ch-ua-platform-version"),
            isMobile: flag(lowered["sec-ch-ua-mobile"]),
            model: value("sec-ch-ua-model"),
            architecture: value("sec-ch-ua-arch"),
            isAvailable: names.contains { lowered[$0] != nil }
        )
    }

    /// `"Chromium";v="131", "Google Chrome";v="131", "Not_A Brand";v="24"`
    /// as pairs, decoys dropped, order kept.
    static func brands(from header: String) -> [ClientHintBrand] {
        split(header, on: ",")
            .compactMap { item -> ClientHintBrand? in
                let parts = split(item, on: ";").map(unquote)
                guard let name = parts.first, !name.isEmpty, !isDecoy(name) else { return nil }
                let version = parts.dropFirst().first.map { part in
                    unquote(part.hasPrefix("v=") ? String(part.dropFirst(2)) : part)
                } ?? ""
                return ClientHintBrand(name: name, version: version)
            }
    }

    /// Splits on `separator` only outside double quotes, because a decoy
    /// brand such as `"Not)A;Brand"` carries the separator inside its name.
    static func split(_ text: String, on separator: Character) -> [String] {
        var parts: [String] = []
        var current = ""
        var inQuotes = false
        for character in text {
            if character == "\"" {
                inQuotes.toggle()
                current.append(character)
            } else if character == separator, !inQuotes {
                parts.append(current)
                current = ""
            } else {
                current.append(character)
            }
        }
        parts.append(current)
        return parts.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    /// Browsers inject a brand such as `Not_A Brand`, `Not)A;Brand` or
    /// `Not.A/Brand` so that code cannot assume a fixed list. The letters
    /// alone always spell `notabrand`, whatever the punctuation of the year.
    static func isDecoy(_ brand: String) -> Bool {
        let letters = brand.lowercased().filter { $0.isLetter }
        return letters == "notabrand"
    }

    /// `?1` is true, `?0` is false, anything else is not an answer.
    static func flag(_ raw: String?) -> Bool? {
        switch raw?.trimmingCharacters(in: .whitespaces) {
        case "?1": true
        case "?0": false
        default: nil
        }
    }

    /// Strips the surrounding quotes and whitespace of a structured-header
    /// string, leaving the value.
    static func unquote(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespaces)
        if text.hasPrefix("\""), text.hasSuffix("\""), text.count >= 2 {
            text = String(text.dropFirst().dropLast())
        }
        return text.trimmingCharacters(in: .whitespaces)
    }

    /// `Windows 11` or `Windows 10` from the platform version, which the
    /// user-agent string cannot tell you.
    ///
    /// Windows 11 reports a platform version of 13.0.0 or above; Windows 10
    /// reports 1.0.0 to 10.0.0. The boundary is Microsoft's, not a guess —
    /// the numbering deliberately jumped. Anything else, or any other
    /// platform, is nil.
    static func windowsVersion(platform: String?, platformVersion: String?) -> String? {
        guard platform?.lowercased() == "windows",
              let major = Scanning.major(of: platformVersion) else { return nil }
        switch major {
        case 13...: return "Windows 11"
        case 1...10: return "Windows 10"
        default: return nil
        }
    }
}
