// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftStrCalc",
    platforms: [
        .iOS(.v12),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftStrCalc",
            targets: ["SwiftStrCalc"]),
    ],
    targets: [
        .target(
            name: "SwiftStrCalc"),
        .testTarget(
            name: "SwiftStrCalcTests",
            dependencies: ["SwiftStrCalc"]),
    ]
)
