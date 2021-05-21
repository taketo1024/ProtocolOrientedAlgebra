// swift-tools-version:5.3
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
            dependencies: []),
        .testTarget(
            name: "SwiftyMathTests",
            dependencies: ["SwiftyMath"]),
    ]
)
