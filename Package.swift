// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftDataTables",
    platforms: [ .iOS(.v17) ],
    products: [
        .library(
            name: "SwiftDataTables",
            targets: ["SwiftDataTables"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftDataTables",
            dependencies: [],
            path: "SwiftDataTables",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]),
        .testTarget(
            name: "SwiftDataTablesTests",
            dependencies: ["SwiftDataTables"],
            path: "Example/SwiftDataTablesTests"),
    ],
    swiftLanguageVersions: [.v5]
)
