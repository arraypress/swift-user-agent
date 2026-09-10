//
//  ClientHints+Windows.swift
//  UserAgent
//

import Foundation

extension ClientHints {

    /// `Windows 11` or `Windows 10`, which the user-agent string cannot say —
    /// both report `Windows NT 10.0`. Needs ``platformVersion``, a high-entropy
    /// hint that arrives only after ``acceptCH`` has been sent. Nil for any
    /// other platform or when the hint is absent.
    public var windowsVersion: String? {
        ClientHintsParsing.windowsVersion(platform: platform, platformVersion: platformVersion)
    }
}
