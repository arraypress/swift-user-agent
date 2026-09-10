//
//  BotEntry.swift
//  UserAgent
//
//  The crawler lists. Kept in sync with ai.robots.txt; they go stale like every list.
//

import Foundation

/// One named crawler and its category.
///
/// Named crawlers are distinctive enough that a case-insensitive substring
/// match is safe. The generic words are not — see ``genericWords`` — and
/// are matched on word boundaries instead.
struct BotEntry: Sendable {

    /// The token as the operator writes it.
    let name: String

    /// What kind of client it is.
    let category: BotCategory

    init(_ name: String, _ category: BotCategory) {
        self.name = name
        self.category = category
    }

    /// The named crawlers, in match order.
    ///
    /// Order matters twice. `Applebot-Extended` (training) precedes `Applebot`
    /// (search). And the assistants that fetch on a person's behalf precede
    /// the corpus crawlers, because `ChatGPT-User/1.0; +https://openai.com/bot`
    /// contains `openai` and would otherwise be filed as a training crawler.
    ///
    /// The AI rows track https://github.com/ai-robots-txt/ai.robots.txt.
    static let named: [BotEntry] = [
        // Assistants fetching a page a person asked about.
        BotEntry("ChatGPT-User", .aiUser),
        BotEntry("ChatGPT Agent", .aiUser),
        BotEntry("OAI-SearchBot", .aiUser),
        BotEntry("Claude-User", .aiUser),
        BotEntry("Claude-SearchBot", .aiUser),
        BotEntry("Perplexity-User", .aiUser),
        BotEntry("MistralAI-User", .aiUser),
        BotEntry("Kimi-User", .aiUser),
        BotEntry("DuckAssistBot", .aiUser),
        BotEntry("Manus-User", .aiUser),

        // Training and corpus crawlers.
        BotEntry("GPTBot", .ai),
        BotEntry("OpenAI", .ai),
        BotEntry("Operator", .ai),
        BotEntry("ClaudeBot", .ai),
        BotEntry("Claude-Web", .ai),
        BotEntry("Claude-Code", .ai),
        BotEntry("anthropic-ai", .ai),
        BotEntry("PerplexityBot", .ai),
        BotEntry("Google-Extended", .ai),
        BotEntry("GoogleOther", .ai),
        BotEntry("Google-NotebookLM", .ai),
        BotEntry("Gemini-Deep-Research", .ai),
        BotEntry("Google-CloudVertexBot", .ai),
        BotEntry("CloudVertexBot", .ai),
        BotEntry("GoogleAgent-Mariner", .ai),
        BotEntry("Applebot-Extended", .ai),
        BotEntry("Amazonbot", .ai),
        BotEntry("bedrockbot", .ai),
        BotEntry("AzureAI-SearchBot", .ai),
        BotEntry("Meta-ExternalAgent", .ai),
        BotEntry("meta-externalagent", .ai),
        BotEntry("meta-externalfetcher", .ai),
        BotEntry("meta-webindexer", .ai),
        BotEntry("cohere-ai", .ai),
        BotEntry("CCBot", .ai),
        BotEntry("ImagesiftBot", .ai),
        BotEntry("Diffbot", .ai),
        BotEntry("YouBot", .ai),
        BotEntry("ExaBot", .ai),
        BotEntry("TavilyBot", .ai),
        BotEntry("LinerBot", .ai),
        BotEntry("iAskBot", .ai),
        BotEntry("PhindBot", .ai),
        BotEntry("kagi-fetcher", .ai),
        BotEntry("Webzio-Extended", .ai),
        BotEntry("Timpibot", .ai),
        BotEntry("omgilibot", .ai),
        BotEntry("Andibot", .ai),
        BotEntry("Bytespider", .ai),
        BotEntry("TikTokSpider", .ai),
        BotEntry("DeepSeekBot", .ai),
        BotEntry("TongyiBot", .ai),
        BotEntry("PanguBot", .ai),
        BotEntry("YiyanBot", .ai),
        BotEntry("ChatGLM-Spider", .ai),
        BotEntry("QuillBot", .ai),
        BotEntry("Devin", .ai),
        BotEntry("Cursor", .ai),
        BotEntry("opencode", .ai),
        BotEntry("Trae", .ai),
        BotEntry("NovaAct", .ai),
        BotEntry("FirecrawlAgent", .ai),
        BotEntry("Crawl4AI", .ai),

        // Search engines.
        BotEntry("Googlebot", .search),
        BotEntry("Google-InspectionTool", .search),
        BotEntry("AdsBot-Google", .search),
        BotEntry("Mediapartners-Google", .search),
        BotEntry("bingbot", .search),
        BotEntry("BingPreview", .search),
        BotEntry("Baiduspider", .search),
        BotEntry("DuckDuckBot", .search),
        BotEntry("YandexBot", .search),
        BotEntry("Slurp", .search),
        BotEntry("Applebot", .search),
        BotEntry("PetalBot", .search),

        // Social unfurlers.
        BotEntry("facebookexternalhit", .social),
        BotEntry("Twitterbot", .social),
        BotEntry("LinkedInBot", .social),
        BotEntry("Pinterestbot", .social),
        BotEntry("TelegramBot", .social),
        BotEntry("Slackbot", .social),
        BotEntry("Discordbot", .social),
        BotEntry("WhatsApp", .social),
        BotEntry("redditbot", .social),

        // SEO.
        BotEntry("SemrushBot", .seo),
        BotEntry("AhrefsBot", .seo),
        BotEntry("MJ12bot", .seo),
        BotEntry("DotBot", .seo),
        BotEntry("DataForSeoBot", .seo),
        BotEntry("Screaming Frog", .seo),

        // Monitoring.
        BotEntry("UptimeRobot", .monitoring),
        BotEntry("Pingdom", .monitoring),
        BotEntry("StatusCake", .monitoring),

        // Scraping sold as a service, and programmatic clients.
        BotEntry("Scrapy", .programmatic),
        BotEntry("ApifyBot", .programmatic),
        BotEntry("Crawlspace", .programmatic),
        BotEntry("VelenPublicWebCrawler", .programmatic),
        BotEntry("img2dataset", .programmatic),
        BotEntry("Panscient", .programmatic),
        BotEntry("HeadlessChrome", .programmatic),
        BotEntry("python-requests", .programmatic),
        BotEntry("python-urllib", .programmatic),
        BotEntry("Go-http-client", .programmatic),
        BotEntry("node-fetch", .programmatic),
        BotEntry("libwww-perl", .programmatic),
        BotEntry("PostmanRuntime", .programmatic),
        BotEntry("insomnia", .programmatic),
        BotEntry("HTTPClient", .programmatic),
        BotEntry("okhttp", .programmatic),
        BotEntry("axios", .programmatic),
        BotEntry("Guzzle", .programmatic),
        BotEntry("aiohttp", .programmatic),
    ]

    /// Words that mark an unnamed crawler, matched on word boundaries.
    static let genericWords: [String] = [
        "bot", "bots", "spider", "crawler", "crawl", "scraper", "archiver",
    ]

    /// Words that mark a programmatic client, matched on word boundaries.
    static let programmaticWords: [String] = [
        "curl", "wget", "java", "ruby", "perl", "php", "python",
    ]
}
