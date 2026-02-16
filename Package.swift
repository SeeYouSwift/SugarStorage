// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SugarStorage",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "SugarStorage", targets: ["SugarStorage"]),
        .library(name: "SugarStorageMocks", targets: ["SugarStorageMocks"])
    ],
    targets: [
        .target(name: "SugarStorage"),
        .target(name: "SugarStorageMocks", dependencies: ["SugarStorage"]),
        .testTarget(
            name: "SugarStorageTests",
            dependencies: ["SugarStorage", "SugarStorageMocks"]
        )
    ]
)
