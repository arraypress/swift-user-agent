//
//  BotTests.swift
//  UserAgent
//
//  Every crawler category from a real string, every row of the named list,
//  the generic words on their boundaries, and the humans who look like bots.
//

import XCTest
@testable import UserAgent

final class BotTests: XCTestCase {

    private func bot(_ ua: String) -> Bot? { UserAgent.parse(ua).bot }

    // MARK: Every category, at least once from a real string

    func testSearchEngines() {
        XCTAssertEqual(bot(UA.googlebot), Bot(name: "Googlebot", category: .search))
        XCTAssertEqual(bot(UA.bingbot), Bot(name: "bingbot", category: .search))
        XCTAssertEqual(bot(UA.applebot), Bot(name: "Applebot", category: .search))
    }

    func testTrainingCrawlers() {
        XCTAssertEqual(bot(UA.gptBot), Bot(name: "GPTBot", category: .ai))
        XCTAssertEqual(bot(UA.claudeBot), Bot(name: "ClaudeBot", category: .ai))
        XCTAssertEqual(bot(UA.perplexityBot), Bot(name: "PerplexityBot", category: .ai))
        XCTAssertEqual(bot(UA.bytespider), Bot(name: "Bytespider", category: .ai))
        XCTAssertEqual(bot(UA.metaExternal)?.category, .ai)
        XCTAssertEqual(bot(UA.googleOther), Bot(name: "GoogleOther", category: .ai))
        XCTAssertEqual(bot(UA.applebotExtended), Bot(name: "Applebot-Extended", category: .ai))
        XCTAssertEqual(bot(UA.deepSeek), Bot(name: "DeepSeekBot", category: .ai))
        XCTAssertEqual(bot(UA.firecrawl), Bot(name: "FirecrawlAgent", category: .ai))
        XCTAssertEqual(bot(UA.bedrock), Bot(name: "bedrockbot", category: .ai))
    }

    func testAssistantsFetchingForAPerson() {
        XCTAssertEqual(bot(UA.chatGPTUser), Bot(name: "ChatGPT-User", category: .aiUser))
        XCTAssertEqual(bot(UA.oaiSearchBot), Bot(name: "OAI-SearchBot", category: .aiUser))
        XCTAssertEqual(bot(UA.claudeUser), Bot(name: "Claude-User", category: .aiUser))
        XCTAssertEqual(bot(UA.perplexityUser), Bot(name: "Perplexity-User", category: .aiUser))
        XCTAssertEqual(bot(UA.mistralUser), Bot(name: "MistralAI-User", category: .aiUser))
        XCTAssertEqual(bot(UA.duckAssist), Bot(name: "DuckAssistBot", category: .aiUser))
    }

    func testSocialUnfurlers() {
        XCTAssertEqual(bot(UA.facebookExternalHit), Bot(name: "facebookexternalhit", category: .social))
        XCTAssertEqual(bot(UA.slackbot), Bot(name: "Slackbot", category: .social))
        XCTAssertEqual(bot(UA.twitterbot), Bot(name: "Twitterbot", category: .social))
        XCTAssertEqual(bot(UA.linkedInBot), Bot(name: "LinkedInBot", category: .social))
    }

    func testSEOCrawlers() {
        XCTAssertEqual(bot(UA.ahrefs), Bot(name: "AhrefsBot", category: .seo))
        XCTAssertEqual(bot(UA.semrush), Bot(name: "SemrushBot", category: .seo))
    }

    func testMonitors() {
        XCTAssertEqual(bot(UA.uptimeRobot), Bot(name: "UptimeRobot", category: .monitoring))
        XCTAssertEqual(bot(UA.pingdom), Bot(name: "Pingdom", category: .monitoring))
    }

    func testProgrammaticClientsByName() {
        XCTAssertEqual(bot(UA.pythonRequests), Bot(name: "python-requests", category: .programmatic))
        XCTAssertEqual(bot(UA.goHTTP), Bot(name: "Go-http-client", category: .programmatic))
        XCTAssertEqual(bot(UA.postman), Bot(name: "PostmanRuntime", category: .programmatic))
        XCTAssertEqual(bot(UA.okhttp), Bot(name: "okhttp", category: .programmatic))
        XCTAssertEqual(bot(UA.axios), Bot(name: "axios", category: .programmatic))
        XCTAssertEqual(bot(UA.scrapy), Bot(name: "Scrapy", category: .programmatic))
        XCTAssertEqual(bot(UA.headlessChrome), Bot(name: "HeadlessChrome", category: .programmatic))
    }

    func testProgrammaticClientsByWordKeepTheTokenAsTheName() {
        XCTAssertEqual(bot(UA.curl), Bot(name: "curl", category: .programmatic))
        XCTAssertEqual(bot(UA.wget), Bot(name: "Wget", category: .programmatic))
        XCTAssertEqual(bot(UA.java), Bot(name: "Java", category: .programmatic))
        XCTAssertEqual(bot(UA.php), Bot(name: "PHP", category: .programmatic))
    }

    func testGenericCrawlersByWord() {
        XCTAssertEqual(bot(UA.genericBot), Bot(name: "Bot", category: .generic))
        XCTAssertEqual(bot(UA.genericSpider), Bot(name: "crawler", category: .generic))
        XCTAssertEqual(bot(UA.genericArchiver), Bot(name: "Archiver", category: .generic))
        XCTAssertEqual(bot("Mozilla/5.0 (compatible; Some Spider/1.0)"), Bot(name: "Spider", category: .generic))
        XCTAssertEqual(bot("Data bots/2")?.name, "bots")
        XCTAssertEqual(bot("Scraper/1.0")?.category, .generic)
        XCTAssertEqual(bot("Site crawl/1.0")?.name, "crawl")
    }

    func testEveryBotCategoryIsReachable() {
        let seen = Set(BotEntry.named.map(\.category) + [BotCategory.generic])
        XCTAssertEqual(seen, Set(BotCategory.allCases))
    }

    // MARK: Every row of the named list

    func testEveryNamedCrawlerIsRecognisedWithItsOwnCategory() {
        // A row an earlier row shadows would come back with the wrong category;
        // this is the test that catches a bad insertion order.
        for entry in BotEntry.named {
            let client = UserAgent.parse("Mozilla/5.0 (compatible; \(entry.name)/1.0)")
            XCTAssertEqual(client.bot?.name.lowercased(), entry.name.lowercased(), entry.name)
            XCTAssertEqual(client.bot?.category, entry.category, entry.name)
            XCTAssertEqual(client.device, .bot, entry.name)
        }
    }

    func testNamedCrawlersMatchIgnoringCase() {
        XCTAssertEqual(bot("googlebot/2.1")?.name, "Googlebot")
        XCTAssertEqual(bot("GOOGLEBOT/2.1")?.category, .search)
        XCTAssertEqual(bot("CURL/8.7.1"), Bot(name: "CURL", category: .programmatic))
    }

    // MARK: The AI split

    func testAnAssistantFetchIsSeparableFromItsTrainingSibling() {
        // Blocking a training crawler is a licensing decision; blocking
        // these means refusing somebody who asked to see the page.
        XCTAssertTrue(UserAgent.parse(UA.chatGPTUser).isAIUserFetch)
        XCTAssertFalse(UserAgent.parse(UA.gptBot).isAIUserFetch)
        XCTAssertTrue(UserAgent.parse(UA.claudeUser).isAIUserFetch)
        XCTAssertFalse(UserAgent.parse(UA.claudeBot).isAIUserFetch)
        XCTAssertTrue(UserAgent.parse(UA.perplexityUser).isAIUserFetch)
        XCTAssertFalse(UserAgent.parse(UA.perplexityBot).isAIUserFetch)
    }

    func testBothKindsAreAI() {
        XCTAssertTrue(UserAgent.parse(UA.chatGPTUser).isAI)
        XCTAssertTrue(UserAgent.parse(UA.gptBot).isAI)
        XCTAssertFalse(UserAgent.parse(UA.googlebot).isAI)
        XCTAssertFalse(UserAgent.parse(UA.chrome).isAI)
        XCTAssertFalse(UserAgent.parse("").isAI)
    }

    func testChatGPTUserIsNotFiledUnderOpenAIByItsContactURL() {
        XCTAssertTrue(UA.chatGPTUser.lowercased().contains("openai"))
        XCTAssertEqual(bot(UA.chatGPTUser)?.category, .aiUser)
    }

    func testApplebotExtendedIsNotFiledAsApplebot() {
        XCTAssertEqual(bot(UA.applebotExtended)?.category, .ai)
        XCTAssertEqual(bot(UA.applebot)?.category, .search)
    }

    // MARK: isBot

    func testCrawlersAreBots() {
        for ua in [UA.googlebot, UA.bingbot, UA.gptBot, UA.claudeBot, UA.perplexityBot, UA.bytespider,
                   UA.facebookExternalHit, UA.slackbot, UA.ahrefs, UA.curl, UA.wget, UA.pythonRequests,
                   UA.goHTTP, UA.postman, UA.genericBot, ""] {
            XCTAssertTrue(UserAgent.parse(ua).isBot, ua)
        }
    }

    func testRealBrowsersAreNotBots() {
        for ua in [UA.chrome, UA.safari, UA.iPhone, UA.android, UA.firefox, UA.edge, UA.bareMozilla] {
            XCTAssertFalse(UserAgent.parse(ua).isBot, ua)
            XCTAssertNil(UserAgent.parse(ua).bot, ua)
        }
    }

    func testAnEmptyOrBlankStringIsABotWithoutAName() {
        XCTAssertTrue(UserAgent.parse("").isBot)
        XCTAssertTrue(UserAgent.parse("   ").isBot)
        XCTAssertNil(UserAgent.parse("").bot)
    }

    // MARK: Word boundaries

    func testACubotPhoneIsNotACrawler() {
        // Cubot is a real Android phone brand. A substring match on "bot"
        // classifies every one of its owners as a crawler.
        XCTAssertNil(bot(UA.cubot))
        XCTAssertEqual(UserAgent.parse(UA.cubot).device, .phone)
    }

    func testAbbottIsNotACrawler() {
        XCTAssertNil(bot(UA.abbott))
    }

    func testRoboticsIsNotACrawler() {
        XCTAssertNil(bot(UA.robotics))
    }

    func testAWordIsBoundedByPunctuationNotOnlySpaces() {
        XCTAssertEqual(bot("Foo-Bot/1.0")?.name, "Foo-Bot")
        XCTAssertEqual(bot("Foo bot/1.0")?.name, "bot")
        XCTAssertEqual(bot("(bot)")?.name, "bot")
        XCTAssertEqual(bot("bot")?.name, "bot")
        XCTAssertNil(bot("Abbot1"))
        XCTAssertNil(bot("1bot"))
    }

    // MARK: Your own list

    func testAdditionalBotsAreRecognisedFirst() {
        let own = Bot(name: "MyCorp-Checker", category: .monitoring)
        let client = UserAgent.parse("MyCorp-Checker/3.0 Googlebot-compatible", additionalBots: [own])
        XCTAssertEqual(client.bot, own)
        XCTAssertEqual(client.device, .bot)
    }

    func testAdditionalBotsMatchIgnoringCase() {
        let own = Bot(name: "Internal-Probe", category: .programmatic)
        XCTAssertEqual(UserAgent.parse("internal-probe/1", additionalBots: [own]).bot, own)
    }

    func testAdditionalBotsDoNotAffectHumans() {
        let own = Bot(name: "Internal-Probe", category: .programmatic)
        XCTAssertNil(UserAgent.parse(UA.chrome, additionalBots: [own]).bot)
    }
}
