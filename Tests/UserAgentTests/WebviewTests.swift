//
//  WebviewTests.swift
//  UserAgent
//
//  Every web-view token, and the two web views found by structure.
//

import XCTest
@testable import UserAgent

final class WebviewTests: XCTestCase {

    private func webview(_ ua: String) -> Webview? { UserAgent.parse(ua).webview }

    func testInstagramOnIOS() { XCTAssertEqual(webview(UA.instagramIOS), .instagram) }
    func testInstagramOnAndroid() { XCTAssertEqual(webview(UA.instagramAndroid), .instagram) }
    func testFacebookOnAndroid() { XCTAssertEqual(webview(UA.facebookAndroid), .facebook) }
    func testFacebookOnIOS() { XCTAssertEqual(webview(UA.facebookIOS), .facebook) }
    func testXOnIOS() { XCTAssertEqual(webview(UA.twitterIOS), .twitter) }
    func testXOnAndroid() { XCTAssertEqual(webview(UA.twitterAndroid), .twitter) }
    func testLINE() { XCTAssertEqual(webview(UA.line), .line) }
    func testWeChat() { XCTAssertEqual(webview(UA.weChat), .wechat) }
    func testSnapchat() { XCTAssertEqual(webview(UA.snapchat), .snapchat) }
    func testTikTok() { XCTAssertEqual(webview(UA.tikTok), .tiktok) }
    func testElectron() { XCTAssertEqual(webview(UA.electron), .electron) }

    func testAndroidWebViewByItsWVToken() {
        XCTAssertEqual(webview(UA.androidWebView), .androidWebView)
    }

    func testTheOldAndroidBrowserByItsVersionToken() {
        XCTAssertEqual(webview(UA.androidStockBrowser), .androidWebView)
    }

    func testAWKWebViewByWhatItLacks() {
        XCTAssertFalse(UA.iOSWebView.contains("Version/"))
        XCTAssertEqual(webview(UA.iOSWebView), .iOSWebView)
    }

    func testAnApplicationBeatsTheSystemWebViewItWraps() {
        XCTAssertTrue(UA.instagramAndroid.contains("wv"))
        XCTAssertEqual(webview(UA.instagramAndroid), .instagram)
    }

    func testRealBrowsersHaveNoWebView() {
        for ua in [UA.chrome, UA.safari, UA.iPhone, UA.iPad, UA.android, UA.androidTablet, UA.firefox,
                   UA.edge, UA.chromeIOS, UA.firefoxIOS, UA.edgeIOS, UA.duckDuckGo, UA.samsung] {
            XCTAssertNil(webview(ua), ua)
        }
    }

    func testTheBrowserUnderneathIsStillReported() {
        XCTAssertEqual(UserAgent.parse(UA.instagramAndroid).browser?.name, "Chrome Mobile")
        XCTAssertEqual(UserAgent.parse(UA.electron).browser?.name, "Chrome")
        XCTAssertNil(UserAgent.parse(UA.instagramIOS).browser)
    }

    func testEveryWebviewHasALabelAndKnowsWhetherItIsAnApp() {
        for webview in Webview.allCases {
            XCTAssertFalse(webview.label.isEmpty, webview.rawValue)
        }
        XCTAssertFalse(Webview.androidWebView.isApp)
        XCTAssertFalse(Webview.iOSWebView.isApp)
        XCTAssertEqual(Webview.androidWebView.label, "WebView")
        XCTAssertEqual(Webview.iOSWebView.label, "WebView")
        for webview in Webview.allCases where webview != .androidWebView && webview != .iOSWebView {
            XCTAssertTrue(webview.isApp, webview.rawValue)
        }
        XCTAssertEqual(Webview.twitter.label, "X")
        XCTAssertEqual(Webview.wechat.label, "WeChat")
    }

    func testEveryWebviewIsReachableFromAString() {
        let seen = Set([UA.instagramIOS, UA.facebookIOS, UA.twitterIOS, UA.line, UA.weChat, UA.snapchat,
                        UA.tikTok, UA.electron, UA.androidWebView, UA.iOSWebView].compactMap(webview))
        XCTAssertEqual(seen, Set(Webview.allCases))
    }

    func testEveryRowOfTheAppTableMatchesItsOwnFirstToken() {
        for pattern in WebviewPattern.apps {
            XCTAssertEqual(ClientParsing.webview(in: "Mozilla/5.0 \(pattern.tokens[0])", os: nil), pattern.webview)
        }
    }
}
