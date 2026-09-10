# Swift User Agent

Browser, engine, operating system, device class and crawler identity from a `User-Agent` string — as typed values, honest about what the string cannot say.

```swift
import UserAgent

let client = UserAgent.parse("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0")
client.browser?.name        // "Firefox"
client.browser?.majorVersion // 133
client.os?.name             // "Windows 10/11" — the string cannot tell them apart
client.device               // .desktop
client.describe             // "Firefox 133 on Windows 10/11"

UserAgent.parse("Mozilla/5.0 (compatible; ClaudeBot/1.0)").bot        // Bot(name: "ClaudeBot", category: .ai)
UserAgent.parse("Mozilla/5.0 (compatible; Claude-User/1.0)").isAIUserFetch  // true — a person asked for the page
```

## Why

Every user-agent library either claims to know things the string does not contain, or classifies a Cubot phone as a crawler. These are the lies, and what is done about each:

| The string says | What people report | What is true |
|---|---|---|
| `Windows NT 10.0` | Windows 10 | Windows 10 **or** 11. The token was frozen deliberately, so the answer is the range, `Windows 10/11`, and ``ClientHints/windowsVersion`` for the real one. |
| `Mac OS X 10_15_7` | macOS 10.15.7 | Whatever the Mac is running. Every current browser pins Catalina, so the version is dropped and `isFrozen` says why. |
| `Macintosh; Intel Mac OS X` from an iPad | a Mac | Probably an iPad. "Request Desktop Website" has been the iPadOS default since 13; the string cannot do better and this package does not pretend to. |
| `Cubot_NOTE_20` | a bot | A phone. `bot` is matched as a whole word, so `Abbott` and `Robotics` are people too. |
| `Chrome/131 … Edg/131` | Chrome | Edge. Every Chromium string says Chrome and every Chrome string says Safari; the branded rows are tried first and the generic ones last. |
| `CriOS/131` | Chrome, Blink | Chrome, WebKit. Every browser on iOS is a shell over Apple's engine. |

## Installation

```swift
.package(url: "https://github.com/arraypress/swift-user-agent.git", from: "0.1.0")
```

Foundation only. No dependencies, every Apple platform, macOS 14+.

## What is it

`UserAgent.parse(_:)` never throws. Each part is independent and each can be missing:

```swift
let client = UserAgent.parse(string)
client.browser    // Browser?  — name, version, majorVersion
client.engine     // Engine    — webkit, blink, gecko, trident, edgeHTML, presto, unknown
client.os         // OperatingSystem? — name, version, isFrozen
client.device     // DeviceClass — phone, tablet, desktop, bot, unknown
client.bot        // Bot?      — name, category
client.webview    // Webview?  — instagram, facebook, androidWebView, iOSWebView, electron …
client.raw        // the string, capped at 512 characters
```

The string is capped at ``UserAgent/maximumLength`` before anything reads it. Nothing legitimate is longer, and the value ends up in log rows and database columns.

An Android tablet is told from a phone by the **absence** of the `Mobile` token. A `WKWebView` on iOS is WebKit without the `Version/` and `Safari` tokens Safari always carries. Instagram, Facebook, X, LINE, WeChat, Snapchat, TikTok and Electron are named by their own tokens, and the browser underneath is still reported where the string names one.

## Is it a bot

```swift
client.isBot       // any crawler, scraper or programmatic client — and an empty string
client.bot?.name   // "Googlebot", "curl", "python-requests"
client.bot?.category  // .search, .ai, .aiUser, .social, .seo, .monitoring, .programmatic, .generic
```

Named crawlers are matched as case-insensitive substrings; they are distinctive enough. The generic words — `bot`, `spider`, `crawler`, `curl`, `python` and the rest — are matched on word boundaries, because a substring match on `bot` files every Cubot owner as a crawler.

An empty user agent counts as a bot. An absent header is not a browser, and a request without one is almost always a script.

This is a heuristic for analytics and segmentation. It is not a security boundary, and nothing it returns should gate access to anything.

## Is it an AI crawler, and which kind

```swift
client.isAI           // a training crawler OR an assistant fetching for a person
client.isAIUserFetch  // only the second kind
```

The split most lists miss. Several operators run separate tokens for crawling a training corpus and for fetching a page a person just asked about: `GPTBot` and `ChatGPT-User`, `PerplexityBot` and `Perplexity-User`, `ClaudeBot` and `Claude-User`. Blocking the first is a licensing decision. Blocking the second means somebody asked to see your page and got an error.

The AI rows track [ai.robots.txt](https://github.com/ai-robots-txt/ai.robots.txt). Lists like this go stale, so add your own without waiting for a release:

```swift
UserAgent.parse(string, additionalBots: [Bot(name: "NewCrawler", category: .ai)])
```

Yours are matched first, and a private probe can be filed under whatever category you choose.

## Client hints

```swift
let hints = ClientHints.parse(headers: request.allHeaderFields)
hints.isAvailable        // false for Firefox and Safari — they send none
hints.platform           // "Windows"
hints.isMobile           // true, false, or nil when absent
hints.brands             // [Chromium 131, Google Chrome 131] — the "Not_A Brand" decoy removed
hints.windowsVersion     // "Windows 11" — needs the platform version, a high-entropy hint
```

Chromium's UA reduction froze the user-agent string; client hints put the data back, in headers, on request. The low-entropy hints arrive by themselves. The high-entropy ones — platform version, model, architecture, full version list — must be asked for: send ``ClientHints/acceptCH`` as an `Accept-CH` response header and the browser includes them on later requests to your origin, so the first request never has them.

Windows 11 reports a platform version of 13.0.0 or above; Windows 10 reports 1.0.0 to 10.0.0. The boundary is Microsoft's, not a guess — the numbering deliberately jumped.

## Building your own

```swift
UserAgent.string(product: "MetricBar", version: "1.4", contact: "https://metricbar.app")
// "MetricBar/1.4 (+https://metricbar.app)"
```

`product/version (+contact)` is the shape crawlers have used for twenty years and the shape an operator reading their logs can act on. Spaces in the product become hyphens, because the product is a token; a bare email address gets `mailto:`.

## Tested

212 tests. Every row of the browser, operating-system, web-view and crawler tables from a real string, including every row that must lose to a more specific one; every enum through Codable and back; the word boundaries around `bot`; the 512 cap at 511, 512 and 513 characters; non-ASCII, blank and bare `Mozilla/5.0` strings; client hints quoted, unquoted, garbled, decoy-only and absent; and the Windows boundary at 13.0.0 and 12.9.9. Fixed strings throughout — a corpus that changes is a test that says nothing.

## Licence

MIT.
