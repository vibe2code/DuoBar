// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReDuoBar",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ReDuoBar", targets: ["ReDuoBar"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "ReDuoBar",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "ReDuoBar",
            resources: [
                .process("Assets.xcassets"),
                .process("Resources/AppIcon.icns")
            ]
        )
    ]
)
