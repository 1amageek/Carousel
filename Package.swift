// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Carousel",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "Carousel",
            targets: ["Carousel"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Carousel",
            dependencies: []),
        .testTarget(
            name: "CarouselTests",
            dependencies: ["Carousel"]),
    ]
)
