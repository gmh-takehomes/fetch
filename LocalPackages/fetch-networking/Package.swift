// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "fetch-networking",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "CoreNetworking",
            targets: [
                "CoreNetworking"
            ]
        ),
        .library(
            name: "NetworkHelpers",
            targets: [
                "NetworkHelpers"
            ]
        ),
        .library(
            name: "NetworkMocks",
            targets: [
                "NetworkMocks"
            ]
        ),
    ],
    targets: [
        .target(
            name: "CoreNetworking",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "NetworkHelpers",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "NetworkMocks",
            dependencies: [
                "CoreNetworking"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CoreNetworkingTests",
            dependencies: [
                "CoreNetworking",
                "NetworkMocks"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "NetworkHelpersTests",
            dependencies: [
                "CoreNetworking",
                "NetworkHelpers"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "NetworkMocksTests",
            dependencies: [
                "CoreNetworking",
                "NetworkMocks"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
