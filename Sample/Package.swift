// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sample",
    dependencies: [
        .package(url: "../", .branch("matrix-improve")),
    ],
    targets: [
        .target(
            name: "Sample",
            dependencies: ["SwiftyMath"],
            path: "Sources/"),
    ]
)
