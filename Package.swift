// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aoc2022",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "aoc2022",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .process("Data")
            ]),
        .testTarget(
            name: "aoc2022Test",
            dependencies: ["aoc2022"]),
    ]
)
