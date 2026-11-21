// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SprintCheckSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SprintCheckSDK",
            targets: ["SprintCheckSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/regulaforensics/FaceSDK-Swift-Package", from: "8.4.0"),
        .package(url: "https://github.com/regulaforensics/FaceCoreBasic-Swift-Package", from: "8.4.0")
    ],
    targets: [
        .target(
            name: "SprintCheckSDK",
            dependencies: [
                .product(name: "FaceSDK", package: "FaceSDK-Swift-Package"),
                .product(name: "FaceCoreBasic", package: "FaceCoreBasic-Swift-Package")
            ],
            path: "SprintCheckSDK",
            resources: [
                .process("Assets")
            ]
        ),
        .testTarget(
            name: "SprintCheckSDKTests",
            dependencies: ["SprintCheckSDK"],
            path: "Tests/SprintCheckSDKTests"
        ),
    ]
)
