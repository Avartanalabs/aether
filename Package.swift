// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Aether",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Aether",
            path: "AETHER",
            // Same reasoning as the canvas app next door: the whole interface is
            // main-thread by nature, and Swift 6's strict isolation buys nothing
            // here but ceremony.
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "AetherTests",
            dependencies: ["Aether"],
            path: "Tests/AetherTests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
