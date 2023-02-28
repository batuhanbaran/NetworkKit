// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkKit",
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1"))
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                "Alamofire"
            ]
        ),
    ]
)
