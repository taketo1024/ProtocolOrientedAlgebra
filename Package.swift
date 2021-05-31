// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swm-core",
    products: [
        .library(
            name: "SwmCore",
            targets: ["SwmCore"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "0.2.0"
        )
    ],
    targets: [
        .target(
            name: "SwmCore",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]),
        .testTarget(
            name: "SwmCoreTests",
            dependencies: ["SwmCore"]),
    ]
)
