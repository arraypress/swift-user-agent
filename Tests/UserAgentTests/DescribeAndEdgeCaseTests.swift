//
//  DescribeAndEdgeCaseTests.swift
//  UserAgent
//
//  The one-line description for every device class, and the strings that
//  break parsers: empty, blank, bare, capped, non-ASCII, wrong case.
//

import XCTest
@testable import UserAgent

final class DescribeTests: XCTestCase {

    private func describe(_ ua: String) -> String { UserAgent.parse(ua).describe }

    func testADesktopBrowser() { XCTAssertEqual(describe(UA.chrome), "Chrome 131 on macOS") }
    func testWindowsKeepsItsRange() { XCTAssertEqual(describe(UA.firefox), "Firefox 133 on Windows 10/11") }
    func testAPhone() { XCTAssertEqual(describe(UA.iPhone), "Safari Mobile 17 on iOS") }
    func testATablet() { XCTAssertEqual(describe(UA.iPad), "Safari Mobile 17 on iPadOS") }
    func testACrawlerIsItsNameAlone() { XCTAssertEqual(describe(UA.googlebot), "Googlebot") }
    func testAGenericCrawlerIsItsToken() { XCTAssertEqual(describe(UA.curl), "curl") }
    func testAnEmptyStringIsUnknown() { XCTAssertEqual(describe(""), "Unknown") }
    func testABlankStringIsUnknown() { XCTAssertEqual(describe("   "), "Unknown") }
    func testABareMozillaIsUnknown() { XCTAssertEqual(describe(UA.bareMozilla), "Unknown") }
    func testAnOSAloneIsTheOS() { XCTAssertEqual(describe(UA.osOnly), "Linux") }
    func testAnApplicationWebViewNamesTheApp() { XCTAssertEqual(describe(UA.instagramIOS), "Instagram on iOS") }
    func testAnApplicationWebViewBeatsTheBrowserItWraps() { XCTAssertEqual(describe(UA.instagramAndroid), "Instagram on Android") }
    func testASystemWebViewWithNoBrowserSaysWebView() { XCTAssertEqual(describe(UA.iOSWebView), "WebView on iOS") }
    func testASystemWebViewDefersToANamedBrowser() { XCTAssertEqual(describe(UA.androidWebView), "Chrome Mobile 131 on Android") }
    func testAnElectronAppIsNamedAsElectron() { XCTAssertEqual(describe(UA.electron), "Electron on macOS") }
    func testAVersionlessBrowserHasNoNumber() { XCTAssertEqual(describe("Mozilla/5.0 (Windows NT 6.1) Firefox/"), "Firefox on Windows 7") }

    func testEveryDeviceClassDescribes() {
        XCTAssertEqual(UserAgent.parse(UA.iPhone).device, .phone)
        XCTAssertEqual(UserAgent.parse(UA.iPad).device, .tablet)
        XCTAssertEqual(UserAgent.parse(UA.chrome).device, .desktop)
        XCTAssertEqual(UserAgent.parse(UA.googlebot).device, .bot)
        XCTAssertEqual(UserAgent.parse("").device, .unknown)
        for ua in [UA.iPhone, UA.iPad, UA.chrome, UA.googlebot, ""] {
            XCTAssertFalse(describe(ua).isEmpty, ua)
        }
    }
}

final class EdgeCaseTests: XCTestCase {

    func testAnEmptyStringParsesToNothing() {
        let client = UserAgent.parse("")
        XCTAssertEqual(client.raw, "")
        XCTAssertNil(client.browser)
        XCTAssertEqual(client.engine, .unknown)
        XCTAssertNil(client.os)
        XCTAssertEqual(client.device, .unknown)
        XCTAssertNil(client.bot)
        XCTAssertNil(client.webview)
    }

    func testWhitespaceOnlyParsesLikeEmpty() {
        let client = UserAgent.parse(" \t ")
        XCTAssertNil(client.browser)
        XCTAssertNil(client.os)
        XCTAssertEqual(client.device, .unknown)
        XCTAssertTrue(client.isBot)
    }

    func testABareMozillaIsADesktopOfNoKnownKind() {
        let client = UserAgent.parse(UA.bareMozilla)
        XCTAssertNil(client.browser)
        XCTAssertNil(client.os)
        XCTAssertEqual(client.engine, .unknown)
        XCTAssertEqual(client.device, .desktop)
        XCTAssertFalse(client.isBot)
    }

    func testTheCapIs512() {
        XCTAssertEqual(UserAgent.maximumLength, 512)
    }

    func testTheRawStringIsCappedAt512Characters() {
        XCTAssertEqual(UserAgent.parse(String(repeating: "a", count: 511)).raw.count, 511)
        XCTAssertEqual(UserAgent.parse(String(repeating: "a", count: 512)).raw.count, 512)
        XCTAssertEqual(UserAgent.parse(String(repeating: "a", count: 513)).raw.count, 512)
        XCTAssertEqual(UserAgent.parse(String(repeating: "a", count: 2000)).raw.count, 512)
    }

    func testTokensBeyondTheCapAreNotRead() {
        let padded = String(repeating: "x", count: 512) + " Googlebot/2.1"
        XCTAssertNil(UserAgent.parse(padded).bot)
    }

    func testNonASCIIDoesNotUpsetTheParse() {
        let client = UserAgent.parse(UA.nonASCII)
        XCTAssertEqual(client.browser?.name, "Chrome")
        XCTAssertEqual(client.os?.name, "macOS")
        XCTAssertEqual(client.device, .desktop)
        XCTAssertTrue(client.raw.contains("🤖"))
    }

    func testCrawlerNamesAreMatchedIgnoringCaseButBrowserTokensAreNot() {
        XCTAssertEqual(UserAgent.parse("bingbot/2.0").bot?.category, .search)
        XCTAssertEqual(UserAgent.parse("BINGBOT/2.0").bot?.category, .search)
        XCTAssertNil(UserAgent.parse("mozilla/5.0 chrome/131.0.0.0").browser)
    }

    func testTheParseNeverThrowsOnGarbage() {
        for junk in ["\u{0}", "////", "Chrome/", "Version/", "(((", "Mac OS X ", "Android ", "🤖🤖🤖", "Windows NT "] {
            _ = UserAgent.parse(junk)
        }
        XCTAssertNil(UserAgent.parse("Chrome/").browser?.version)
        XCTAssertNil(UserAgent.parse("Android ").os?.version)
    }

    func testAVersionWithATrailingDotIsTrimmed() {
        XCTAssertEqual(Scanning.version(after: "Chrome/", in: "Chrome/131. Safari"), "131")
    }
}
