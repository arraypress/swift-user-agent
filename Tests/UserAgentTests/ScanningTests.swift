//
//  ScanningTests.swift
//  UserAgent
//
//  The primitives, tested without a table in the way.
//

import XCTest
@testable import UserAgent

final class ScanningTests: XCTestCase {

    func testVersionAfterAToken() {
        XCTAssertEqual(Scanning.version(after: "Chrome/", in: "Chrome/131.0.0.0 Safari/537.36"), "131.0.0.0")
        XCTAssertEqual(Scanning.version(after: "Version/", in: "Version/17.6 Mobile/15E148"), "17.6")
        XCTAssertEqual(Scanning.version(after: "rv:", in: "Trident/7.0; rv:11.0) like Gecko"), "11.0")
    }

    func testUnderscoresReadAsDots() {
        XCTAssertEqual(Scanning.version(after: "iPhone OS ", in: "CPU iPhone OS 17_6 like Mac OS X"), "17.6")
        XCTAssertEqual(Scanning.version(after: "Mac OS X ", in: "Intel Mac OS X 10_15_7)"), "10.15.7")
    }

    func testAMissingTokenOrNumberIsNil() {
        XCTAssertNil(Scanning.version(after: "Chrome/", in: "Firefox/133.0"))
        XCTAssertNil(Scanning.version(after: "Chrome/", in: "Chrome/"))
        XCTAssertNil(Scanning.version(after: "Chrome/", in: "Chrome/abc"))
        XCTAssertNil(Scanning.version(after: "Chrome/", in: ""))
    }

    func testMajorVersion() {
        XCTAssertEqual(Scanning.major(of: "131.0.0.0"), 131)
        XCTAssertEqual(Scanning.major(of: "7"), 7)
        XCTAssertNil(Scanning.major(of: nil))
        XCTAssertNil(Scanning.major(of: ""))
        XCTAssertNil(Scanning.major(of: "abc"))
    }

    func testContainsAnyIsCaseSensitive() {
        XCTAssertTrue(Scanning.containsAny(["Mobile"], in: "Chrome/1 Mobile Safari"))
        XCTAssertFalse(Scanning.containsAny(["Mobile"], in: "example.com/mobile"))
        XCTAssertFalse(Scanning.containsAny([], in: "anything"))
    }

    func testFirstTokenFollowsTableOrder() {
        XCTAssertEqual(Scanning.firstToken(of: ["Edg/", "Chrome/"], in: "Chrome/1 Edg/2"), "Edg/")
        XCTAssertNil(Scanning.firstToken(of: ["Edg/"], in: "Chrome/1"))
    }

    func testContainsIgnoringCase() {
        XCTAssertTrue(Scanning.containsIgnoringCase("googlebot", in: "Mozilla/5.0 (compatible; Googlebot/2.1)"))
        XCTAssertFalse(Scanning.containsIgnoringCase("bingbot", in: "Googlebot"))
    }

    func testWordTokenHonoursBoundaries() {
        XCTAssertEqual(Scanning.wordToken("bot", in: "SomeNew Bot/1.0"), "Bot")
        XCTAssertEqual(Scanning.wordToken("bot", in: "Foo-Bot/1.0"), "Foo-Bot")
        XCTAssertEqual(Scanning.wordToken("bot", in: "bot"), "bot")
        XCTAssertEqual(Scanning.wordToken("bot", in: "(BOT)"), "BOT")
        XCTAssertNil(Scanning.wordToken("bot", in: "Cubot_NOTE_20"))
        XCTAssertNil(Scanning.wordToken("bot", in: "Abbott/2.0"))
        XCTAssertNil(Scanning.wordToken("bot", in: "Robotics/1.0"))
        XCTAssertNil(Scanning.wordToken("bot", in: ""))
    }

    func testWordTokenKeepsLookingPastAFalseStart() {
        // The first "bot" is inside Cubot; the second stands alone.
        XCTAssertEqual(Scanning.wordToken("bot", in: "Cubot_NOTE_20 bot/1.0"), "bot")
    }

    func testWordTokenSurvivesNonASCII() {
        XCTAssertEqual(Scanning.wordToken("bot", in: "日本語 bot/1.0 🤖"), "bot")
        XCTAssertNil(Scanning.wordToken("bot", in: "日本語bot"))
    }
}
