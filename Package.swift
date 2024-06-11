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
        .package(url: "https://gitlab.akbars.tech/abo/ios.designsystem", .upToNextMinor(from: "3.3.0")),
        .package(url: "https://gitlab.akbars.tech/abo/ios-architecture-table", .upToNextMinor(from: "2.0.0")),
        .package(url: "https://gitlab.akbars.tech/abo/ios-services", .upToNextMinor(from: "0.2.0"))
    ],
    targets: [
        .target(
            name: "BottomSheetService",
            dependencies: [
                .product(name: "DesignSystem", package: "ios.designsystem"),
                .product(name: "ArchitectureTableView", package: "ios-architecture-table"),
                .product(name: "Services", package: "ios-services")
            ]
        ),
        .testTarget(
            name: "BottomSheetServiceTests",
            dependencies: ["BottomSheetService"]),
    ]
)
