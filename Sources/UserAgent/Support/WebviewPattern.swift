//
//  WebviewPattern.swift
//  UserAgent
//
//  The in-app browser table.
//

import Foundation

/// One row of the web-view table: the tokens an app adds to the string.
///
/// Named applications come first because they wrap the system web view and
/// carry its tokens too — an Instagram page on Android is also `wv`.
struct WebviewPattern: Sendable {

    /// The web view reported.
    let webview: Webview

    /// Any one of these must appear (case-sensitive).
    let tokens: [String]

    init(_ webview: Webview, tokens: [String]) {
        self.webview = webview
        self.tokens = tokens
    }

    /// The application rows. The two bare system web views are recognised by
    /// structure rather than a token — see ``ClientParsing/webview(in:os:)``.
    static let apps: [WebviewPattern] = [
        WebviewPattern(.instagram, tokens: ["Instagram"]),
        WebviewPattern(.facebook, tokens: ["FBAN", "FBAV", "FB_IAB", "FB4A"]),
        WebviewPattern(.twitter, tokens: ["Twitter for", "TwitterAndroid", "Twitter/"]),
        WebviewPattern(.line, tokens: ["Line/"]),
        WebviewPattern(.wechat, tokens: ["MicroMessenger"]),
        WebviewPattern(.snapchat, tokens: ["Snapchat"]),
        WebviewPattern(.tiktok, tokens: ["musical_ly", "BytedanceWebview", "TikTok"]),
        WebviewPattern(.electron, tokens: ["Electron/"]),
    ]
}
