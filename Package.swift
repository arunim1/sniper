// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Sniper",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Sniper",
            targets: ["Sniper"]
        )
    ],
    dependencies: [
        // Sparkle temporarily disabled for initial build
        // .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "Sniper",
            dependencies: [
                // .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
