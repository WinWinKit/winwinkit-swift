// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WinWinKit-Swift",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WinWinKit",
            targets: ["WinWinKit"]
        ),
    ],
    targets: [
        .target(
            name: "WinWinKit"
        ),
        .testTarget(
            name: "WinWinKitTests",
            dependencies: ["WinWinKit"]
        ),
    ]
)
