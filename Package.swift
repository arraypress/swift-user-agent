// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-user-agent",
    platforms: [
        .macOS(.v14), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1),
    ],
    products: [
        .library(name: "UserAgent", targets: ["UserAgent"]),
    ],
    targets: [
        .target(name: "UserAgent"),
        .testTarget(name: "UserAgentTests", dependencies: ["UserAgent"]),
    ]
)
