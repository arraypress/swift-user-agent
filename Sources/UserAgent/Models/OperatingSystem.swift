//
//  OperatingSystem.swift
//  UserAgent
//

import Foundation

/// An operating system and, when the string can be believed, its version.
///
/// Three of the platforms lie, and no pattern can fix them:
///
/// - **Windows 11 is undetectable from a user agent.** It reports
///   `Windows NT 10.0`, byte-identical to Windows 10. The token was frozen
///   deliberately — bumping it would break decades of sniffing code — so the
///   name comes back as `Windows 10/11`. Client hints can tell them apart;
///   see ``ClientHints/windowsVersion``.
/// - **macOS reports 10.15.7 forever.** Every current browser froze the
///   version at Catalina, whatever the Mac is running, so a captured
///   `10.15.x` is meaningless and is dropped rather than repeated.
/// - **iPads usually claim to be Macs.** "Request Desktop Website" has been
///   the iPadOS default since 13, so most iPad traffic arrives with a macOS
///   string and a ``DeviceClass/desktop`` classification, and nothing in the
///   string says otherwise.
public struct OperatingSystem: Sendable, Hashable, Codable {

    /// The name, e.g. `macOS`, `iOS`, `iPadOS`, `Android`, `Windows 10/11`.
    public let name: String

    /// The version as declared, e.g. `17.6`. Nil when the string carries
    /// none, or carries one that is known to be frozen.
    public let version: String?

    /// Whether the platform freezes its version in the string. When this is
    /// true, ``version`` is nil on purpose: reporting a number the string
    /// cannot know would be worse than reporting none.
    public let isFrozen: Bool

    /// Why a frozen version is dropped, for a log line or a tooltip.
    public static let frozenExplanation =
        "The platform reports a fixed version in the user agent (Windows NT 10.0 for both Windows 10 and 11; macOS 10.15.7 for every current release), so the real version is not in the string."

    /// Builds an operating system by hand; the parser is the usual source.
    public init(name: String, version: String?, isFrozen: Bool) {
        self.name = name
        self.version = version
        self.isFrozen = isFrozen
    }
}
