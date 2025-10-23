// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SnipIt",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SnipIt",
            targets: ["SnipIt"]
        )
    ],
    dependencies: [
        // Sparkle temporarily disabled for initial build
        // .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "SnipIt",
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
