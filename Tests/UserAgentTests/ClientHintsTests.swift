//
//  ClientHintsTests.swift
//  UserAgent
//
//  The headers, quoted and not, present and not, and the Windows boundary.
//

import XCTest
@testable import UserAgent

final class ClientHintsTests: XCTestCase {

    private let chromeOnWindows11: [String: String] = [
        "Sec-CH-UA": "\"Chromium\";v=\"131\", \"Google Chrome\";v=\"131\", \"Not_A Brand\";v=\"24\"",
        "Sec-CH-UA-Mobile": "?0",
        "Sec-CH-UA-Platform": "\"Windows\"",
        "Sec-CH-UA-Platform-Version": "\"15.0.0\"",
        "Sec-CH-UA-Arch": "\"x86\"",
        "Sec-CH-UA-Model": "\"\"",
        "Sec-CH-UA-Full-Version-List": "\"Chromium\";v=\"131.0.6778.86\", \"Google Chrome\";v=\"131.0.6778.86\", \"Not_A Brand\";v=\"24.0.0.0\"",
    ]

    func testAFullSetOfHints() {
        let hints = ClientHints.parse(headers: chromeOnWindows11)
        XCTAssertTrue(hints.isAvailable)
        XCTAssertEqual(hints.brands, [ClientHintBrand(name: "Chromium", version: "131"), ClientHintBrand(name: "Google Chrome", version: "131")])
        XCTAssertEqual(hints.fullVersions.map(\.version), ["131.0.6778.86", "131.0.6778.86"])
        XCTAssertEqual(hints.platform, "Windows")
        XCTAssertEqual(hints.platformVersion, "15.0.0")
        XCTAssertEqual(hints.isMobile, false)
        XCTAssertEqual(hints.architecture, "x86")
        XCTAssertNil(hints.model, "an empty quoted model is no model")
        XCTAssertEqual(hints.windowsVersion, "Windows 11")
    }

    func testNothingForBrowsersThatSendNoHints() {
        let hints = ClientHints.parse(headers: [:])
        XCTAssertFalse(hints.isAvailable)
        XCTAssertNil(hints.platform)
        XCTAssertNil(hints.platformVersion)
        XCTAssertNil(hints.isMobile)
        XCTAssertNil(hints.model)
        XCTAssertNil(hints.architecture)
        XCTAssertNil(hints.windowsVersion)
        XCTAssertEqual(hints.brands, [])
        XCTAssertEqual(hints.fullVersions, [])
    }

    func testUnrelatedHeadersDoNotCountAsHints() {
        XCTAssertFalse(ClientHints.parse(headers: ["User-Agent": UA.chrome, "Accept": "*/*"]).isAvailable)
    }

    func testHeaderNamesMatchIgnoringCase() {
        let hints = ClientHints.parse(headers: ["sec-ch-ua-platform": "\"macOS\"", "SEC-CH-UA-MOBILE": "?1"])
        XCTAssertEqual(hints.platform, "macOS")
        XCTAssertEqual(hints.isMobile, true)
        XCTAssertTrue(hints.isAvailable)
    }

    func testUnquotedValuesAreReadToo() {
        let hints = ClientHints.parse(headers: ["Sec-CH-UA-Platform": "Android", "Sec-CH-UA-Model": "Pixel 8"])
        XCTAssertEqual(hints.platform, "Android")
        XCTAssertEqual(hints.model, "Pixel 8")
    }

    func testWhitespaceAroundValuesIsIgnored() {
        XCTAssertEqual(ClientHints.parse(headers: ["Sec-CH-UA-Platform": "  \" Linux \"  "]).platform, "Linux")
        XCTAssertEqual(ClientHints.parse(headers: ["Sec-CH-UA-Mobile": " ?1 "]).isMobile, true)
    }

    func testTheMobileFlag() {
        XCTAssertEqual(ClientHintsParsing.flag("?1"), true)
        XCTAssertEqual(ClientHintsParsing.flag("?0"), false)
        XCTAssertNil(ClientHintsParsing.flag("?2"))
        XCTAssertNil(ClientHintsParsing.flag("true"))
        XCTAssertNil(ClientHintsParsing.flag(""))
        XCTAssertNil(ClientHintsParsing.flag(nil))
    }

    func testDecoyBrandsAreDroppedWhateverTheirPunctuation() {
        for decoy in ["Not_A Brand", "Not A;Brand", "Not)A;Brand", "Not/A)Brand", "Not.A/Brand", "Not:A-Brand", "not-a-brand"] {
            XCTAssertTrue(ClientHintsParsing.isDecoy(decoy), decoy)
        }
        XCTAssertFalse(ClientHintsParsing.isDecoy("Google Chrome"))
        XCTAssertFalse(ClientHintsParsing.isDecoy("Brave"))
    }

    func testBrandsThatAreOnlyDecoysComeBackEmpty() {
        XCTAssertEqual(ClientHintsParsing.brands(from: "\"Not_A Brand\";v=\"24\", \"Not)A;Brand\";v=\"8\""), [])
    }

    func testGarbledBrandListsReadWhatTheyCan() {
        XCTAssertEqual(ClientHintsParsing.brands(from: "\"Chromium\";v=131"), [ClientHintBrand(name: "Chromium", version: "131")])
        XCTAssertEqual(ClientHintsParsing.brands(from: "Chromium"), [ClientHintBrand(name: "Chromium", version: "")])
        XCTAssertEqual(ClientHintsParsing.brands(from: "\"Chromium\";v=\"131\",,, ,"), [ClientHintBrand(name: "Chromium", version: "131")])
        XCTAssertEqual(ClientHintsParsing.brands(from: ""), [])
        XCTAssertEqual(ClientHintsParsing.brands(from: "\"\";v=\"1\""), [])
    }

    func testSplittingHonoursQuotes() {
        XCTAssertEqual(ClientHintsParsing.split("\"Not)A;Brand\";v=\"8\"", on: ";"), ["\"Not)A;Brand\"", "v=\"8\""])
        XCTAssertEqual(ClientHintsParsing.split("a, b,,c", on: ","), ["a", "b", "c"])
        XCTAssertEqual(ClientHintsParsing.split("", on: ","), [])
        XCTAssertEqual(ClientHintsParsing.split("\"x,y\", z", on: ","), ["\"x,y\"", "z"])
    }

    func testUnquoteStripsOnlyAMatchedPair() {
        XCTAssertEqual(ClientHintsParsing.unquote("\"Windows\""), "Windows")
        XCTAssertEqual(ClientHintsParsing.unquote("Windows"), "Windows")
        XCTAssertEqual(ClientHintsParsing.unquote("\"Windows"), "\"Windows")
        XCTAssertEqual(ClientHintsParsing.unquote("\""), "\"")
        XCTAssertEqual(ClientHintsParsing.unquote("\"\""), "")
    }

    func testTheWindowsBoundaryIsMicrosofts() {
        // Windows 11 reports 13.0.0 and up; Windows 10 reports 1.0.0 to 10.0.0.
        XCTAssertEqual(ClientHintsParsing.windowsVersion(platform: "Windows", platformVersion: "13.0.0"), "Windows 11")
        XCTAssertEqual(ClientHintsParsing.windowsVersion(platform: "Windows", platformVersion: "15.0.0"), "Windows 11")
        XCTAssertEqual(ClientHintsParsing.windowsVersion(platform: "Windows", platformVersion: "10.0.0"), "Windows 10")
        XCTAssertEqual(ClientHintsParsing.windowsVersion(platform: "Windows", platformVersion: "1.0.0"), "Windows 10")
        XCTAssertNil(ClientHintsParsing.windowsVersion(platform: "Windows", platformVersion: "12.9.9"), "no Windows reports 11 or 12")
        XCTAssertNil(ClientHintsParsing.windowsVersion(platform: "Windows", platformVersion: "0.3.0"), "Windows 7 and 8 are below the range")
        XCTAssertNil(ClientHintsParsing.windowsVersion(platform: "Windows", platformVersion: nil))
        XCTAssertNil(ClientHintsParsing.windowsVersion(platform: "Windows", platformVersion: "garbage"))
        XCTAssertNil(ClientHintsParsing.windowsVersion(platform: "macOS", platformVersion: "15.0.0"))
        XCTAssertNil(ClientHintsParsing.windowsVersion(platform: nil, platformVersion: "15.0.0"))
    }

    func testWindowsVersionThroughTheModel() {
        let win10 = ClientHints.parse(headers: ["Sec-CH-UA-Platform": "\"Windows\"", "Sec-CH-UA-Platform-Version": "\"10.0.0\""])
        XCTAssertEqual(win10.windowsVersion, "Windows 10")
        XCTAssertNil(ClientHints.parse(headers: ["Sec-CH-UA-Platform": "\"macOS\""]).windowsVersion)
    }

    func testTheAcceptCHValueAsksForTheHighEntropyHints() {
        XCTAssertTrue(ClientHints.acceptCH.contains("Sec-CH-UA-Platform-Version"))
        XCTAssertTrue(ClientHints.acceptCH.contains("Sec-CH-UA-Model"))
        XCTAssertTrue(ClientHints.acceptCH.contains("Sec-CH-UA-Full-Version-List"))
        XCTAssertTrue(ClientHints.acceptCH.contains("Sec-CH-UA-Arch"))
    }

    func testDuplicateHeaderNamesInDifferentCasesKeepTheFirst() {
        let hints = ClientHints.parse(headers: ["Sec-CH-UA-Platform": "\"Windows\"", "sec-ch-ua-platform": "\"Linux\""])
        XCTAssertTrue(["Windows", "Linux"].contains(hints.platform))
    }
}
