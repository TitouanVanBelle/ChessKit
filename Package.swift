// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChessKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "ChessKit",
            targets: ["ChessKit"]),
    ],
    dependencies: [
        .package(name: "Chess", url: "https://github.com/TitouanVanBelle/Chess", .branch("master")),
        .package(url: "https://github.com/PureLayout/PureLayout", .upToNextMajor(from: "3.1.6"))

    ],
    targets: [
        .target(
            name: "ChessKit",
            dependencies: ["Chess", "PureLayout"],
            resources: [.process("Resources")]
        )
    ]
)
