// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BottomSheetService",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BottomSheetService",
            targets: ["BottomSheetService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/silentcrewtechnology/iOS.Architecture.Table.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/silentcrewtechnology/iOS.Service.Routing.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/silentcrewtechnology/iOS.Services.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "BottomSheetService",
            dependencies: [
                .product(name: "ArchitectureTableView", package: "ios-architecture-table"),
                .product(name: "Router", package: "ios-service-routing"),
                .product(name: "Services", package: "ios-services")
            ]
        ),
    ]
)
