// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "DrMaxNavigationDemoMac",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(name: "swift-drmax-navigation", path: "../.."),
        .package(name: "DrMaxNavigationDemoCore", path: "../DrMaxNavigationDemoCore")
    ],
    targets: [
        .executableTarget(
            name: "DrMaxNavigationDemoMac",
            dependencies: [
                .product(name: "DrMaxNavigation", package: "swift-drmax-navigation"),
                .product(name: "DrMaxNavigationDemoCore", package: "DrMaxNavigationDemoCore")
            ]
        )
    ]
)
