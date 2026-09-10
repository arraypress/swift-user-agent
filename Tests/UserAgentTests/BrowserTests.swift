//
//  BrowserTests.swift
//  UserAgent
//
//  Every row of the browser table, and every row that must lose to a more
//  specific one. The strings are real; the order is the algorithm.
//

import XCTest
@testable import UserAgent

final class BrowserTests: XCTestCase {

    private func browser(_ ua: String) -> Browser? { UserAgent.parse(ua).browser }

    // MARK: Every row

    func testChromeOnAMac() {
        let b = browser(UA.chrome)
        XCTAssertEqual(b?.name, "Chrome")
        XCTAssertEqual(b?.version, "131.0.0.0")
        XCTAssertEqual(b?.majorVersion, 131)
    }

    func testChromiumIsReportedAsChrome() {
        XCTAssertEqual(browser(UA.chromium)?.name, "Chrome")
        XCTAssertEqual(browser(UA.chromium)?.majorVersion, 131)
    }

    func testSafariOnAMac() {
        let b = browser(UA.safari)
        XCTAssertEqual(b?.name, "Safari")
        XCTAssertEqual(b?.version, "17.6")
        XCTAssertEqual(b?.majorVersion, 17)
    }

    func testSafariOnAnIPhoneIsSafariMobile() {
        XCTAssertEqual(browser(UA.iPhone)?.name, "Safari Mobile")
        XCTAssertEqual(browser(UA.iPhone)?.version, "17.6")
    }

    func testSafariOnAnIPadIsSafariMobile() {
        XCTAssertEqual(browser(UA.iPad)?.name, "Safari Mobile")
    }

    func testSafariOnAnIPodIsSafariMobile() {
        XCTAssertEqual(browser(UA.iPod)?.name, "Safari Mobile")
        XCTAssertEqual(browser(UA.iPod)?.version, "15.6")
    }

    func testFirefox() {
        XCTAssertEqual(browser(UA.firefox)?.name, "Firefox")
        XCTAssertEqual(browser(UA.firefox)?.version, "133.0")
        XCTAssertEqual(browser(UA.firefox)?.majorVersion, 133)
    }

    func testChromeOnAndroidIsChromeMobile() {
        XCTAssertEqual(browser(UA.android)?.name, "Chrome Mobile")
        XCTAssertEqual(browser(UA.android)?.majorVersion, 131)
    }

    func testChromeOnAnAndroidTabletIsPlainChrome() {
        // No Mobile token, no Mobile name. The tablet is in the device class.
        XCTAssertEqual(browser(UA.androidTablet)?.name, "Chrome")
    }

    func testEdgeOnWindows() {
        XCTAssertEqual(browser(UA.edge)?.name, "Edge")
        XCTAssertEqual(browser(UA.edge)?.version, "131.0.0.0")
    }

    func testEdgeOnAndroid() {
        XCTAssertEqual(browser(UA.edgeAndroid)?.name, "Edge")
        XCTAssertEqual(browser(UA.edgeAndroid)?.majorVersion, 131)
    }

    func testEdgeOnIOS() {
        XCTAssertEqual(browser(UA.edgeIOS)?.name, "Edge")
        XCTAssertEqual(browser(UA.edgeIOS)?.majorVersion, 131)
    }

    func testTheOriginalEdge() {
        XCTAssertEqual(browser(UA.edgeLegacy)?.name, "Edge")
        XCTAssertEqual(browser(UA.edgeLegacy)?.version, "18.18363")
    }

    func testOperaReadsItsVersionFromTheOPRToken() {
        XCTAssertEqual(browser(UA.opera)?.name, "Opera")
        XCTAssertEqual(browser(UA.opera)?.version, "116.0.0.0")
    }

    func testOldOperaReadsItsVersionFromTheVersionTokenNotTheEngineNumber() {
        // "Opera/9.80" is the engine's number and never changed; the browser is 12.16.
        XCTAssertEqual(browser(UA.operaPresto)?.name, "Opera")
        XCTAssertEqual(browser(UA.operaPresto)?.version, "12.16")
    }

    func testOperaMini() {
        XCTAssertEqual(browser(UA.operaMini)?.name, "Opera Mini")
        XCTAssertEqual(browser(UA.operaMini)?.version, "9.80")
    }

    func testBrave() {
        XCTAssertEqual(browser(UA.brave)?.name, "Brave")
        XCTAssertEqual(browser(UA.brave)?.version, "131")
    }

    func testVivaldi() {
        XCTAssertEqual(browser(UA.vivaldi)?.name, "Vivaldi")
        XCTAssertEqual(browser(UA.vivaldi)?.majorVersion, 7)
    }

    func testSamsungInternet() {
        XCTAssertEqual(browser(UA.samsung)?.name, "Samsung Internet")
        XCTAssertEqual(browser(UA.samsung)?.version, "27.0")
    }

    func testUCBrowser() {
        XCTAssertEqual(browser(UA.ucBrowser)?.name, "UC Browser")
        XCTAssertEqual(browser(UA.ucBrowser)?.majorVersion, 13)
    }

    func testDuckDuckGo() {
        XCTAssertEqual(browser(UA.duckDuckGo)?.name, "DuckDuckGo")
        XCTAssertEqual(browser(UA.duckDuckGo)?.version, "7")
    }

    func testChromeOnIOS() {
        XCTAssertEqual(browser(UA.chromeIOS)?.name, "Chrome iOS")
        XCTAssertEqual(browser(UA.chromeIOS)?.version, "131.0.6778.73")
    }

    func testFirefoxOnIOS() {
        XCTAssertEqual(browser(UA.firefoxIOS)?.name, "Firefox iOS")
        XCTAssertEqual(browser(UA.firefoxIOS)?.version, "133.0")
    }

    func testInternetExplorer11HidesItsVersionInRV() {
        XCTAssertEqual(browser(UA.ie11)?.name, "Internet Explorer")
        XCTAssertEqual(browser(UA.ie11)?.version, "11.0")
    }

    func testInternetExplorer10() {
        XCTAssertEqual(browser(UA.ie10)?.name, "Internet Explorer")
        XCTAssertEqual(browser(UA.ie10)?.version, "10.0")
    }

    func testChromeOnChromeOS() {
        XCTAssertEqual(browser(UA.chromeOS)?.name, "Chrome")
    }

    func testAnElectronAppIsChromeUnderneath() {
        XCTAssertEqual(browser(UA.electron)?.name, "Chrome")
        XCTAssertEqual(browser(UA.electron)?.majorVersion, 120)
    }

    // MARK: Precedence — every string that contains a more generic token

    func testEdgeBeatsChromeBecauseItsStringContainsChrome() {
        XCTAssertTrue(UA.edge.contains("Chrome/"))
        XCTAssertEqual(browser(UA.edge)?.name, "Edge")
    }

    func testOperaBeatsChrome() {
        XCTAssertTrue(UA.opera.contains("Chrome/"))
        XCTAssertEqual(browser(UA.opera)?.name, "Opera")
    }

    func testBraveBeatsChrome() {
        XCTAssertEqual(browser(UA.brave)?.name, "Brave")
    }

    func testVivaldiBeatsChrome() {
        XCTAssertEqual(browser(UA.vivaldi)?.name, "Vivaldi")
    }

    func testSamsungBeatsChromeMobile() {
        XCTAssertTrue(UA.samsung.contains("Chrome/") && UA.samsung.contains("Mobile"))
        XCTAssertEqual(browser(UA.samsung)?.name, "Samsung Internet")
    }

    func testUCBrowserBeatsChromeMobile() {
        XCTAssertEqual(browser(UA.ucBrowser)?.name, "UC Browser")
    }

    func testChromeIOSBeatsSafariMobile() {
        XCTAssertTrue(UA.chromeIOS.contains("Safari"))
        XCTAssertEqual(browser(UA.chromeIOS)?.name, "Chrome iOS")
    }

    func testEdgeIOSBeatsSafariMobile() {
        // The only iOS shell that also carries Version/, so Safari Mobile would match it.
        XCTAssertTrue(UA.edgeIOS.contains("Version/"))
        XCTAssertEqual(browser(UA.edgeIOS)?.name, "Edge")
    }

    func testChromeBeatsSafariBecauseEveryChromeStringSaysSafari() {
        XCTAssertTrue(UA.chrome.contains("Safari"))
        XCTAssertEqual(browser(UA.chrome)?.name, "Chrome")
    }

    func testSafariMobileBeatsSafari() {
        XCTAssertEqual(browser(UA.iPhone)?.name, "Safari Mobile")
    }

    func testTheIPadInDesktopModeIsPlainSafariBecauseItsStringIsAMacString() {
        XCTAssertEqual(UA.iPadDesktopMode, UA.safari)
        XCTAssertEqual(browser(UA.iPadDesktopMode)?.name, "Safari")
    }

    func testWindowsPhoneIsTheOriginalEdge() {
        XCTAssertEqual(browser(UA.windowsPhone)?.name, "Edge")
        XCTAssertEqual(browser(UA.windowsPhone)?.version, "15.14977")
    }

    // MARK: Nothing

    func testAWebViewWithNoBrowserTokensHasNoBrowser() {
        XCTAssertNil(browser(UA.iOSWebView))
    }

    func testABareMozillaHasNoBrowser() {
        XCTAssertNil(browser(UA.bareMozilla))
    }

    func testBrowserTokensAreCaseSensitive() {
        // "chrome/131" is not a token any browser sends; matching it would invent one.
        XCTAssertNil(browser("Mozilla/5.0 chrome/131.0.0.0 safari/537.36"))
    }

    func testEveryRowOfTheTableMatchesItsOwnFirstToken() {
        // A row nothing can reach is a row that is not tested anywhere else.
        for pattern in BrowserPattern.all {
            let synthetic = ([pattern.tokens[0] + "1.0"] + pattern.requires).joined(separator: " ")
            XCTAssertNotNil(ClientParsing.browser(in: synthetic), pattern.name)
        }
    }
}
