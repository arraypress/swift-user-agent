//
//  OSPattern.swift
//  UserAgent
//
//  The operating-system table, and the versions that must not be believed.
//

import Foundation

/// One row of the operating-system table.
///
/// The frozen fields exist because two platforms report a fixed version
/// whatever they are running. `Windows NT 10.0` is Windows 10 and Windows
/// 11 alike, so that row is frozen outright and named for the range. macOS
/// pins `10.15.7`, so any `10.15.x` is dropped while an older, still-honest
/// `10.13.6` is kept.
struct OSPattern: Sendable {

    /// The name reported in ``OperatingSystem/name``.
    let name: String

    /// Any one of these must appear (case-sensitive).
    let tokens: [String]

    /// None of these may appear.
    let excludes: [String]

    /// Where the version follows, tried in order. Empty means no version.
    let versionTokens: [String]

    /// Whether every version this row could report is a lie.
    let isFrozen: Bool

    /// Version prefixes that are known lies; a match drops the version and
    /// marks the result frozen.
    let frozenPrefixes: [String]

    init(
        _ name: String,
        tokens: [String],
        excludes: [String] = [],
        versionTokens: [String] = [],
        isFrozen: Bool = false,
        frozenPrefixes: [String] = []
    ) {
        self.name = name
        self.tokens = tokens
        self.excludes = excludes
        self.versionTokens = versionTokens
        self.isFrozen = isFrozen
        self.frozenPrefixes = frozenPrefixes
    }

    /// The table, most specific first. iOS precedes macOS because an iPhone
    /// string ends `like Mac OS X`; Windows Phone precedes Android because
    /// its strings claimed Android compatibility.
    static let all: [OSPattern] = [
        OSPattern("Windows Phone", tokens: ["Windows Phone"], versionTokens: ["Windows Phone "]),
        OSPattern("iOS", tokens: ["iPhone OS ", "iPod"], versionTokens: ["iPhone OS ", "CPU OS "]),
        OSPattern("iPadOS", tokens: ["iPad"], versionTokens: ["CPU OS ", "iPhone OS "]),
        OSPattern("Android", tokens: ["Android"], versionTokens: ["Android "]),

        // Deliberately not "Windows 10" — see the type's note. Reporting a
        // version this cannot know would be worse than reporting the range.
        OSPattern("Windows 10/11", tokens: ["Windows NT 10.0"], isFrozen: true),
        OSPattern("Windows 8.1", tokens: ["Windows NT 6.3"]),
        OSPattern("Windows 8", tokens: ["Windows NT 6.2"]),
        OSPattern("Windows 7", tokens: ["Windows NT 6.1"]),
        OSPattern("Windows Vista", tokens: ["Windows NT 6.0"]),
        OSPattern("Windows XP", tokens: ["Windows NT 5.1", "Windows NT 5.2"]),
        OSPattern("Windows", tokens: ["Windows NT "], versionTokens: ["Windows NT "]),

        OSPattern("Chrome OS", tokens: ["CrOS"], versionTokens: ["CrOS x86_64 ", "CrOS aarch64 ", "CrOS armv7l ", "CrOS i686 "]),

        // A `10.15.x` here is what every current browser sends on every Mac.
        OSPattern("macOS", tokens: ["Mac OS X"], versionTokens: ["Mac OS X "], frozenPrefixes: ["10.15"]),

        OSPattern("Ubuntu", tokens: ["Ubuntu"]),
        OSPattern("FreeBSD", tokens: ["FreeBSD"]),
        OSPattern("Linux", tokens: ["Linux"], excludes: ["Android"]),
    ]
}
