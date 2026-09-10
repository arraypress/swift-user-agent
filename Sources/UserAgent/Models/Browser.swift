//
//  Browser.swift
//  UserAgent
//

import Foundation

/// A browser and the version it declared.
///
/// The name is the product a person would recognise — `Chrome`, `Safari
/// Mobile`, `Samsung Internet` — not the engine underneath it. Mobile
/// variants of Chrome and Safari carry their own names because the two
/// behave differently enough that analytics usually wants them apart.
public struct Browser: Sendable, Hashable, Codable {

    /// The product name, e.g. `Chrome`, `Firefox iOS`, `Internet Explorer`.
    public let name: String

    /// The version as declared, e.g. `131.0.0.0`. Nil when the string names
    /// the browser without a number.
    public let version: String?

    /// The first component of ``version`` as a number, for "Chrome 131".
    public let majorVersion: Int?

    /// Builds a browser by hand; the parser is the usual source.
    public init(name: String, version: String?, majorVersion: Int?) {
        self.name = name
        self.version = version
        self.majorVersion = majorVersion
    }
}
