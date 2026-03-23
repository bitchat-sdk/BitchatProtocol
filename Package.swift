// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BitchatProtocol",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BitchatProtocol",
            targets: ["BitchatProtocol"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bitchat-sdk/BitLogger.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "BitchatProtocol",
            dependencies: [
                .product(name: "BitLogger", package: "BitLogger")
            ],
            path: "Sources/BitchatProtocol"
        ),
        .testTarget(
            name: "BitchatProtocolTests",
            dependencies: ["BitchatProtocol"],
            path: "Tests/BitchatProtocolTests"
        )
    ]
)
