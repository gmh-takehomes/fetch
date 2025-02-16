// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "fetch-recipes",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Recipes",
            targets: ["Recipes"]),
    ],
    dependencies: [
        .package(path: "../fetch-networking"),
    ],
    targets: [
        .target(
            name: "Recipes",
            dependencies: [
                .product(name: "CoreNetworking", package: "fetch-networking"),
                .product(name: "NetworkHelpers", package: "fetch-networking")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "RecipesTests",
            dependencies: [
                "Recipes",
                .product(name: "CoreNetworking", package: "fetch-networking"),
                .product(name: "NetworkMocks", package: "fetch-networking"),
            ],
            resources: [.process("Resources")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
