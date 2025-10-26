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
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Sniper",
            dependencies: [],
            path: "Sources"
        )
    ]
)
