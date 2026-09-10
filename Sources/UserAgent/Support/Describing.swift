//
//  Describing.swift
//  UserAgent
//
//  One line for a log row or an order record.
//

import Foundation

/// Turns a ``Client`` into the short line a person would write.
enum Describing {

    /// `Chrome 131 on macOS`, `Googlebot`, `Instagram on iOS`, or `Unknown`.
    ///
    /// A crawler is its name and nothing else. An application web view is
    /// named over the browser it wraps, because "Instagram on Android" is
    /// what explains the missing download button and "Electron on macOS"
    /// what explains a session that is not a browser at all; a bare system
    /// web view defers to the browser when one is named. The major version
    /// alone, because `131.0.6778.73` helps nobody reading a log.
    static func describe(_ client: Client) -> String {
        if let bot = client.bot { return bot.name }
        if client.raw.trimmingCharacters(in: .whitespaces).isEmpty { return "Unknown" }

        let os = client.os?.name
        if let webview = client.webview, webview.isApp {
            return join(webview.label, os)
        }
        if let browser = client.browser {
            let label = browser.majorVersion.map { "\(browser.name) \($0)" } ?? browser.name
            return join(label, os)
        }
        if let webview = client.webview {
            return join(webview.label, os)
        }
        return os ?? "Unknown"
    }

    /// `label on os`, or whichever half exists.
    private static func join(_ label: String, _ os: String?) -> String {
        os.map { "\(label) on \($0)" } ?? label
    }
}
