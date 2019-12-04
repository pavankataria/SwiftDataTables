// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SwiftDataTables",
    platforms: [ .iOS(.v9) ],
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
            path: "SwiftDataTables"),
        .testTarget(
            name: "SwiftDataTablesTests",
            dependencies: ["SwiftDataTables"],
            path: "Example/SwiftDataTablesTests"),
    ],
    swiftLanguageVersions: [.v5]
)
