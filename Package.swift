// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyMath",
    products: [
        .library(
            name: "SwiftyMath",
            targets: ["SwiftyMath"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftyMath",
            dependencies: [],
            path: "Sources/SwiftyMath"),
        .testTarget(
            name: "SwiftyMathTests",
            dependencies: ["SwiftyMath"]),
        .target(
            name: "SwiftyMath-Sample",
            dependencies: ["SwiftyMath"],
            path: "Sources/Sample"),
    ]
)
