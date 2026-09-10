//
//  ClientHints.swift
//  UserAgent
//

import Foundation

/// User-Agent Client Hints — the replacement for sniffing, and the only way
/// to answer some questions at all.
///
/// Chromium's UA reduction froze the user-agent string: the Windows version,
/// the macOS version and the device model were removed or pinned. Those are
/// not gaps in ``UserAgent/parse(_:additionalBots:)`` that better patterns
/// could close; the data is no longer in the string. Client hints put it
/// back, in headers, on request.
///
/// **Low-entropy hints arrive automatically** — `Sec-CH-UA`,
/// `Sec-CH-UA-Mobile`, `Sec-CH-UA-Platform`. **High-entropy hints must be
/// asked for**: send ``acceptCH`` as an `Accept-CH` response header and the
/// browser includes them on later requests to your origin, so the first
/// request never has them.
///
/// Only Chromium browsers send these. Firefox and Safari send nothing, so
/// every field here is nil there and the parsed ``Client`` remains the
/// fallback.
public struct ClientHints: Sendable, Hashable, Codable {

    /// The brand/version pairs from `Sec-CH-UA`, decoys removed.
    public let brands: [ClientHintBrand]

    /// The brand/version pairs from `Sec-CH-UA-Full-Version-List`, decoys
    /// removed. High-entropy: requires ``acceptCH``.
    public let fullVersions: [ClientHintBrand]

    /// The platform name, e.g. `Windows`, `macOS`, `Android`.
    public let platform: String?

    /// The platform version. High-entropy: requires ``acceptCH``.
    public let platformVersion: String?

    /// Whether the browser reports itself as mobile. More reliable than any
    /// user-agent heuristic, because the browser is answering rather than
    /// being guessed at. Nil when the hint is absent.
    public let isMobile: Bool?

    /// The device model, e.g. `Pixel 8`. High-entropy, and only populated on
    /// mobile; empty on desktop.
    public let model: String?

    /// The CPU architecture, e.g. `x86`, `arm`. High-entropy.
    public let architecture: String?

    /// Whether any client-hint header was present at all — false for
    /// Firefox and Safari.
    public let isAvailable: Bool

    /// A reasonable `Accept-CH` value. Each hint requested is more
    /// fingerprinting surface, so ask only for what you will use.
    public static let acceptCH = "Sec-CH-UA-Platform-Version, Sec-CH-UA-Model, Sec-CH-UA-Full-Version-List, Sec-CH-UA-Arch"

    /// Builds hints by hand; ``ClientHints/parse(headers:)`` is the usual source.
    public init(
        brands: [ClientHintBrand],
        fullVersions: [ClientHintBrand],
        platform: String?,
        platformVersion: String?,
        isMobile: Bool?,
        model: String?,
        architecture: String?,
        isAvailable: Bool
    ) {
        self.brands = brands
        self.fullVersions = fullVersions
        self.platform = platform
        self.platformVersion = platformVersion
        self.isMobile = isMobile
        self.model = model
        self.architecture = architecture
        self.isAvailable = isAvailable
    }
}
