// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InAppKit",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
        .watchOS(.v10),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "InAppKit",
            targets: ["InAppKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kolos65/Mockable.git", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "InAppKit",
            dependencies: [
                .product(name: "Mockable", package: "Mockable"),
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "InAppKitTests",
            dependencies: [
                "InAppKit",
                .product(name: "Mockable", package: "Mockable"),
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),
    ]
)
