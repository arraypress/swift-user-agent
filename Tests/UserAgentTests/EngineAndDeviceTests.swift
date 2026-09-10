//
//  EngineAndDeviceTests.swift
//  UserAgent
//
//  Every engine value and every device class, from strings that send them.
//

import XCTest
@testable import UserAgent

final class EngineTests: XCTestCase {

    private func engine(_ ua: String) -> Engine { UserAgent.parse(ua).engine }

    func testSafariIsWebKit() { XCTAssertEqual(engine(UA.safari), .webkit) }
    func testChromeIsBlink() { XCTAssertEqual(engine(UA.chrome), .blink) }
    func testEdgeIsBlink() { XCTAssertEqual(engine(UA.edge), .blink) }
    func testFirefoxIsGecko() { XCTAssertEqual(engine(UA.firefox), .gecko) }
    func testInternetExplorerIsTrident() { XCTAssertEqual(engine(UA.ie11), .trident) }
    func testTheOriginalEdgeIsEdgeHTML() { XCTAssertEqual(engine(UA.edgeLegacy), .edgeHTML) }
    func testOldOperaIsPresto() { XCTAssertEqual(engine(UA.operaPresto), .presto) }
    func testOperaMiniIsPresto() { XCTAssertEqual(engine(UA.operaMini), .presto) }
    func testABareMozillaHasNoEngine() { XCTAssertEqual(engine(UA.bareMozilla), .unknown) }

    func testEveryBrowserOnIOSIsWebKit() {
        // Apple requires it; the brand is a shell.
        XCTAssertEqual(engine(UA.chromeIOS), .webkit)
        XCTAssertEqual(engine(UA.firefoxIOS), .webkit)
        XCTAssertEqual(engine(UA.edgeIOS), .webkit)
        XCTAssertEqual(engine(UA.iPad), .webkit)
    }

    func testLikeGeckoInAWebKitStringIsNotGecko() {
        XCTAssertTrue(UA.chrome.contains("like Gecko"))
        XCTAssertEqual(engine(UA.chrome), .blink)
    }

    func testAnElectronAppIsBlink() { XCTAssertEqual(engine(UA.electron), .blink) }
}

final class DeviceTests: XCTestCase {

    private func device(_ ua: String) -> DeviceClass { UserAgent.parse(ua).device }

    func testAMacIsDesktop() { XCTAssertEqual(device(UA.chrome), .desktop) }
    func testWindowsIsDesktop() { XCTAssertEqual(device(UA.firefox), .desktop) }
    func testLinuxIsDesktop() { XCTAssertEqual(device(UA.linuxChrome), .desktop) }
    func testAnIPhoneIsAPhone() { XCTAssertEqual(device(UA.iPhone), .phone) }
    func testAnIPodIsAPhone() { XCTAssertEqual(device(UA.iPod), .phone) }
    func testAnIPadIsATablet() { XCTAssertEqual(device(UA.iPad), .tablet) }
    func testAnAndroidPhoneIsAPhone() { XCTAssertEqual(device(UA.android), .phone) }
    func testAWindowsPhoneIsAPhone() { XCTAssertEqual(device(UA.windowsPhone), .phone) }
    func testABlackBerryIsAPhone() { XCTAssertEqual(device(UA.blackBerry), .phone) }
    func testOperaMiniIsAPhone() { XCTAssertEqual(device(UA.operaMini), .phone) }
    func testAKindleIsATablet() { XCTAssertEqual(device(UA.kindle), .tablet) }
    func testACrawlerIsABot() { XCTAssertEqual(device(UA.googlebot), .bot) }
    func testAnEmptyStringIsUnknown() { XCTAssertEqual(device(""), .unknown) }
    func testWhitespaceIsUnknown() { XCTAssertEqual(device("   "), .unknown) }
    func testABareMozillaIsDesktop() { XCTAssertEqual(device(UA.bareMozilla), .desktop) }

    func testAnAndroidTabletLacksTheMobileToken() {
        XCTAssertFalse(UA.androidTablet.contains("Mobile"))
        XCTAssertEqual(device(UA.androidTablet), .tablet)
        XCTAssertEqual(device(UA.android), .phone)
    }

    func testTheIPadInDesktopModeIsDesktop() {
        // "Request Desktop Website" sends a Mac string. The string cannot do better.
        XCTAssertEqual(device(UA.iPadDesktopMode), .desktop)
    }

    func testIsMobileCoversPhonesAndTabletsOnly() {
        XCTAssertTrue(UserAgent.parse(UA.iPhone).isMobile)
        XCTAssertTrue(UserAgent.parse(UA.androidTablet).isMobile)
        XCTAssertFalse(UserAgent.parse(UA.chrome).isMobile)
        XCTAssertFalse(UserAgent.parse(UA.googlebot).isMobile)
        XCTAssertFalse(UserAgent.parse("").isMobile)
    }

    func testEveryDeviceClassIsReachable() {
        let seen = Set([UA.chrome, UA.iPhone, UA.iPad, UA.googlebot, ""].map { UserAgent.parse($0).device })
        XCTAssertEqual(seen, Set(DeviceClass.allCases))
    }
}
