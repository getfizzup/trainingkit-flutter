// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "trainingkit_flutter",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        .library(name: "trainingkit-flutter", targets: ["trainingkit_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // FizzUp TrainingKit iOS SDK, distributed as a Swift package whose
        // `TrainingKit` product is a binary target (TrainingKit.xcframework).
        .package(
            url: "https://github.com/getfizzup/trainingkit-ios-sdk.git",
            .upToNextMajor(from: "2.6.0")
        )
    ],
    targets: [
        .target(
            name: "trainingkit_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "TrainingKit", package: "trainingkit-ios-sdk")
            ]
        )
    ]
)
