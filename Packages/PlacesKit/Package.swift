// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PlacesKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PlacesKit",
            targets: ["PlacesKit"]
        )
    ],
    targets: [
        .target(name: "PlacesKit"),
        .testTarget(
            name: "PlacesKitTests",
            dependencies: ["PlacesKit"]
        )
    ]
)
