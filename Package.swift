// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DuoBar",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DuoBar", targets: ["DuoBar"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "DuoBar",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "DuoBar",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
