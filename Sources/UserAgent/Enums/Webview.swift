//
//  Webview.swift
//  UserAgent
//

import Foundation

/// The in-app or embedded browser hosting the page, when there is one.
///
/// A page opened from an Instagram post renders in Instagram's own web
/// view, not in Safari or Chrome, and that changes what works: downloads,
/// popups, payment sheets and cookies all behave differently. The browser
/// underneath is still reported in ``Client/browser`` where the string
/// names one.
public enum Webview: String, Sendable, Hashable, Codable, CaseIterable {

    /// Android's system WebView, marked by a `wv` token or a `Version/4.0`
    /// that Chrome proper never sends.
    case androidWebView

    /// A `WKWebView` on iOS: WebKit without the `Version/` and `Safari`
    /// tokens Safari always carries.
    case iOSWebView

    /// Facebook's in-app browser (`FBAN`, `FBAV`, `FB_IAB`).
    case facebook

    /// Instagram's in-app browser.
    case instagram

    /// X's in-app browser.
    case twitter

    /// LINE's in-app browser.
    case line

    /// WeChat's in-app browser (`MicroMessenger`).
    case wechat

    /// Snapchat's in-app browser.
    case snapchat

    /// TikTok's in-app browser (`musical_ly`, `BytedanceWebview`).
    case tiktok

    /// An Electron desktop application.
    case electron

    /// The name a person would use, for ``Client/describe``.
    public var label: String {
        switch self {
        case .androidWebView, .iOSWebView: "WebView"
        case .facebook: "Facebook"
        case .instagram: "Instagram"
        case .twitter: "X"
        case .line: "LINE"
        case .wechat: "WeChat"
        case .snapchat: "Snapchat"
        case .tiktok: "TikTok"
        case .electron: "Electron"
        }
    }

    /// Whether this names a specific application rather than a bare
    /// system web view.
    public var isApp: Bool {
        switch self {
        case .androidWebView, .iOSWebView: false
        default: true
        }
    }
}
