//
//  BuilderAndCodableTests.swift
//  UserAgent
//
//  The outgoing string, and every type through Codable and back.
//

import XCTest
@testable import UserAgent

final class BuilderTests: XCTestCase {

    func testProductVersionAndContact() {
        XCTAssertEqual(UserAgent.string(product: "MetricBar", version: "1.4", contact: "https://metricbar.app"),
                       "MetricBar/1.4 (+https://metricbar.app)")
    }

    func testWithoutAContact() {
        XCTAssertEqual(UserAgent.string(product: "MetricBar", version: "1.4"), "MetricBar/1.4")
        XCTAssertEqual(UserAgent.string(product: "MetricBar", version: "1.4", contact: nil), "MetricBar/1.4")
        XCTAssertEqual(UserAgent.string(product: "MetricBar", version: "1.4", contact: ""), "MetricBar/1.4")
        XCTAssertEqual(UserAgent.string(product: "MetricBar", version: "1.4", contact: "   "), "MetricBar/1.4")
    }

    func testAnEmailContactBecomesAMailtoLink() {
        XCTAssertEqual(UserAgent.string(product: "Tool", version: "1", contact: "ops@example.com"),
                       "Tool/1 (+mailto:ops@example.com)")
        XCTAssertEqual(UserAgent.string(product: "Tool", version: "1", contact: "mailto:ops@example.com"),
                       "Tool/1 (+mailto:ops@example.com)")
    }

    func testSpacesAndSlashesInTheProductBecomeHyphens() {
        XCTAssertEqual(UserAgent.string(product: "My Fetch Tool", version: "2.0"), "My-Fetch-Tool/2.0")
        XCTAssertEqual(UserAgent.string(product: "a/b", version: "1"), "a-b/1")
        XCTAssertEqual(UserAgent.string(product: "  padded  ", version: " 1.0 "), "padded/1.0")
    }

    func testTheResultParsesAsAProgrammaticClientNotAHuman() {
        let client = UserAgent.parse(UserAgent.string(product: "MetricBar", version: "1.4", contact: "https://metricbar.app"))
        XCTAssertNil(client.browser)
        XCTAssertEqual(client.device, .desktop, "a bare product token is not a crawler word; declare one if you want to be filed as a bot")
    }
}

final class CodableTests: XCTestCase {

    private func roundTrip<T: Codable & Equatable>(_ value: T, file: StaticString = #filePath, line: UInt = #line) throws {
        let data = try JSONEncoder().encode(value)
        let back = try JSONDecoder().decode(T.self, from: data)
        XCTAssertEqual(back, value, file: file, line: line)
    }

    func testEveryEngine() throws { for value in Engine.allCases { try roundTrip(value) } }
    func testEveryDeviceClass() throws { for value in DeviceClass.allCases { try roundTrip(value) } }
    func testEveryBotCategory() throws { for value in BotCategory.allCases { try roundTrip(value) } }
    func testEveryWebview() throws { for value in Webview.allCases { try roundTrip(value) } }

    func testEnumsEncodeAsTheirNames() throws {
        XCTAssertEqual(String(data: try JSONEncoder().encode(Engine.webkit), encoding: .utf8), "\"webkit\"")
        XCTAssertEqual(String(data: try JSONEncoder().encode(BotCategory.aiUser), encoding: .utf8), "\"aiUser\"")
    }

    func testAParsedClientRoundTrips() throws {
        for ua in [UA.chrome, UA.iPhone, UA.googlebot, UA.instagramAndroid, UA.electron, ""] {
            try roundTrip(UserAgent.parse(ua))
        }
    }

    func testTheModelsRoundTrip() throws {
        try roundTrip(Browser(name: "Chrome", version: "131.0", majorVersion: 131))
        try roundTrip(Browser(name: "Chrome", version: nil, majorVersion: nil))
        try roundTrip(OperatingSystem(name: "macOS", version: nil, isFrozen: true))
        try roundTrip(Bot(name: "Googlebot", category: .search))
        try roundTrip(ClientHintBrand(name: "Chromium", version: "131"))
        try roundTrip(ClientHints.parse(headers: ["Sec-CH-UA-Platform": "\"Windows\"", "Sec-CH-UA-Mobile": "?0"]))
        try roundTrip(ClientHints.parse(headers: [:]))
    }

    func testTheModelsAreHashable() {
        let a = UserAgent.parse(UA.chrome)
        let b = UserAgent.parse(UA.chrome)
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.hashValue, b.hashValue)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testPublicInitialisersBuildWhatTheParserBuilds() {
        let hand = Client(
            raw: UA.googlebot,
            browser: nil,
            engine: .unknown,
            os: nil,
            device: .bot,
            bot: Bot(name: "Googlebot", category: .search),
            webview: nil
        )
        XCTAssertEqual(hand, UserAgent.parse(UA.googlebot))
    }
}
