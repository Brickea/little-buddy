// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LittleBuddy",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "LittleBuddy", targets: ["LittleBuddy"])
    ],
    targets: [
        .target(
            name: "LittleBuddy",
            path: "Sources/LittleBuddy"
        ),
        .testTarget(
            name: "LittleBuddyTests",
            dependencies: ["LittleBuddy"],
            path: "Sources/LittleBuddyTests"
        )
    ]
)
