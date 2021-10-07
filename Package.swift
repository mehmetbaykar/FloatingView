// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FloatingView",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "FloatingView",
            targets: ["FloatingView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FloatingView",
            dependencies: []),
    ]
)
