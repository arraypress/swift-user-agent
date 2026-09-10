//
//  OperatingSystemTests.swift
//  UserAgent
//
//  Every row of the operating-system table, and the versions that must not
//  be believed.
//

import XCTest
@testable import UserAgent

final class OperatingSystemTests: XCTestCase {

    private func os(_ ua: String) -> OperatingSystem? { UserAgent.parse(ua).os }

    // MARK: Apple

    func testMacOSDropsTheFrozenVersion() {
        let mac = os(UA.chrome)
        XCTAssertEqual(mac?.name, "macOS")
        XCTAssertNil(mac?.version)
        XCTAssertEqual(mac?.isFrozen, true)
    }

    func testFirefoxOnMacFreezesAtTwoComponents() {
        // "Mac OS X 10.15" with no patch is the same lie shorter.
        let mac = os(UA.firefoxMac)
        XCTAssertEqual(mac?.name, "macOS")
        XCTAssertNil(mac?.version)
        XCTAssertEqual(mac?.isFrozen, true)
    }

    func testAnOlderMacVersionIsStillBelieved() {
        let mac = os(UA.safariOldMac)
        XCTAssertEqual(mac?.version, "10.13.6")
        XCTAssertEqual(mac?.isFrozen, false)
    }

    func testIOSReadsUnderscoresAsDots() {
        let ios = os(UA.iPhone)
        XCTAssertEqual(ios?.name, "iOS")
        XCTAssertEqual(ios?.version, "17.6")
        XCTAssertEqual(ios?.isFrozen, false)
    }

    func testAnIPodIsIOS() {
        XCTAssertEqual(os(UA.iPod)?.name, "iOS")
        XCTAssertEqual(os(UA.iPod)?.version, "15.6")
    }

    func testAnIPadIsIPadOS() {
        XCTAssertEqual(os(UA.iPad)?.name, "iPadOS")
        XCTAssertEqual(os(UA.iPad)?.version, "17.6")
    }

    func testIOSBeatsMacOSBecauseAnIPhoneStringSaysLikeMacOSX() {
        XCTAssertTrue(UA.iPhone.contains("Mac OS X"))
        XCTAssertEqual(os(UA.iPhone)?.name, "iOS")
    }

    func testTheIPadInDesktopModeIsReportedAsAMac() {
        // Nothing in the string says otherwise; see OperatingSystem's note.
        XCTAssertEqual(os(UA.iPadDesktopMode)?.name, "macOS")
    }

    // MARK: Windows

    func testWindows11IsNotClaimedFromAUserAgent() {
        // Windows 11 reports "Windows NT 10.0", identical to Windows 10.
        // Claiming to know which is a lie; the range is the honest answer.
        let windows = os(UA.firefox)
        XCTAssertEqual(windows?.name, "Windows 10/11")
        XCTAssertNil(windows?.version)
        XCTAssertEqual(windows?.isFrozen, true)
    }

    func testWindows81() {
        XCTAssertEqual(os(UA.windows81)?.name, "Windows 8.1")
        XCTAssertEqual(os(UA.windows81)?.isFrozen, false)
    }

    func testWindows8() {
        XCTAssertEqual(os(UA.windows8)?.name, "Windows 8")
    }

    func testWindows7() {
        XCTAssertEqual(os(UA.windows7)?.name, "Windows 7")
    }

    func testWindowsVista() {
        XCTAssertEqual(os(UA.windowsVista)?.name, "Windows Vista")
    }

    func testWindowsXP() {
        XCTAssertEqual(os(UA.windowsXP)?.name, "Windows XP")
    }

    func testAFutureWindowsNTNumberIsReportedAsWindowsWithItsNumber() {
        let windows = os(UA.windowsFuture)
        XCTAssertEqual(windows?.name, "Windows")
        XCTAssertEqual(windows?.version, "11.0")
        XCTAssertEqual(windows?.isFrozen, false)
    }

    func testWindowsPhoneBeatsAndroidBecauseItsStringClaimedAndroid() {
        XCTAssertTrue(UA.windowsPhone.contains("Android"))
        XCTAssertEqual(os(UA.windowsPhone)?.name, "Windows Phone")
        XCTAssertEqual(os(UA.windowsPhone)?.version, "10.0")
    }

    // MARK: Everything else

    func testAndroid() {
        XCTAssertEqual(os(UA.android)?.name, "Android")
        XCTAssertEqual(os(UA.android)?.version, "14")
    }

    func testChromeOSReadsTheVersionAfterTheArchitecture() {
        XCTAssertEqual(os(UA.chromeOS)?.name, "Chrome OS")
        XCTAssertEqual(os(UA.chromeOS)?.version, "14541.0.0")
    }

    func testUbuntuBeatsGenericLinux() {
        XCTAssertTrue(UA.ubuntuFirefox.contains("Linux"))
        XCTAssertEqual(os(UA.ubuntuFirefox)?.name, "Ubuntu")
    }

    func testGenericLinux() {
        XCTAssertEqual(os(UA.linuxChrome)?.name, "Linux")
        XCTAssertNil(os(UA.linuxChrome)?.version)
    }

    func testFreeBSD() {
        XCTAssertEqual(os(UA.freeBSD)?.name, "FreeBSD")
    }

    func testAndroidIsNotLinuxEvenThoughItSaysLinux() {
        XCTAssertTrue(UA.android.contains("Linux"))
        XCTAssertEqual(os(UA.android)?.name, "Android")
    }

    func testUnrecognisedStringsHaveNoOS() {
        XCTAssertNil(os(UA.bareMozilla))
        XCTAssertNil(os("something else entirely"))
    }

    func testTheFrozenExplanationSaysWhy() {
        XCTAssertTrue(OperatingSystem.frozenExplanation.contains("Windows NT 10.0"))
        XCTAssertTrue(OperatingSystem.frozenExplanation.contains("10.15.7"))
    }

    func testEveryRowOfTheTableMatchesItsOwnFirstToken() {
        for pattern in OSPattern.all {
            XCTAssertNotNil(ClientParsing.os(in: "Mozilla/5.0 (\(pattern.tokens[0]) 1.0)"), pattern.name)
        }
    }
}
