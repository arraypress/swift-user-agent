//
//  Engine.swift
//  UserAgent
//

import Foundation

/// The rendering engine behind a browser.
///
/// Worth knowing separately from the brand because on iOS it is always
/// WebKit — Chrome, Firefox and Edge there are shells over Apple's engine,
/// so a WebKit-only bug reproduces in all of them.
public enum Engine: String, Sendable, Hashable, Codable, CaseIterable {

    /// Safari, and every browser on iOS and iPadOS.
    case webkit

    /// Chrome, Edge, Opera, Brave, Vivaldi, Samsung Internet, Electron.
    case blink

    /// Firefox.
    case gecko

    /// Internet Explorer.
    case trident

    /// The original Edge, before it moved to Chromium.
    case edgeHTML

    /// Opera before version 15, and Opera Mini.
    case presto

    /// No engine token the parser recognises.
    case unknown
}
