//
//  ClientHintBrand.swift
//  UserAgent
//

import Foundation

/// One brand/version pair from a `Sec-CH-UA` header.
///
/// A Chromium browser lists several — `Chromium`, its own brand, and a decoy
/// such as `Not_A Brand` injected so that code cannot assume a fixed list.
/// The decoys are filtered out before you see this.
public struct ClientHintBrand: Sendable, Hashable, Codable {

    /// The brand, e.g. `Google Chrome`.
    public let name: String

    /// The version — a major version from `Sec-CH-UA`, a full one from
    /// `Sec-CH-UA-Full-Version-List`.
    public let version: String

    /// Builds a brand by hand; the header parser is the usual source.
    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
}
