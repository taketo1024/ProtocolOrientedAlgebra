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
    ],
    targets: [
        .target(
            name: "SwmCore",
            dependencies: []),
        .testTarget(
            name: "SwmCoreTests",
            dependencies: ["SwmCore"]),
    ]
)
