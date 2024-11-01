// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkAPI",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NetworkAPI",
            targets: ["NetworkAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/eStoyann/SimpleNetworkKit.git", branch: "main"),
        .package(name: "DomainModels", path: "/Users/estoyan/Development/Tutorials/FlickrPhotos/Modules/DomainModels")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NetworkAPI",
            dependencies: ["SimpleNetworkKit", "DomainModels"]),
        .testTarget(
            name: "NetworkAPITests",
            dependencies: ["NetworkAPI"]
        ),
    ]
)
