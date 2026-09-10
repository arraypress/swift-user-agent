//
//  DeviceClass.swift
//  UserAgent
//

import Foundation

/// The shape of the device, as far as the string admits it.
///
/// An Android tablet is told from a phone by the **absence** of the `Mobile`
/// token, which is one of the less helpful decisions in the platform; an
/// iPad in desktop mode is indistinguishable from a Mac and lands on
/// ``desktop``.
public enum DeviceClass: String, Sendable, Hashable, Codable, CaseIterable {

    /// A phone-shaped device.
    case phone

    /// A tablet-shaped device.
    case tablet

    /// Anything that is not a phone, tablet or crawler — including iPads
    /// asking for the desktop site.
    case desktop

    /// A crawler, scraper or programmatic client.
    case bot

    /// An empty string. An absent user agent is not a browser, but it is not
    /// a known device either.
    case unknown
}
