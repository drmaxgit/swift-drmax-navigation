// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "DrMaxNavigationDemoCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "DrMaxNavigationDemoCore",
            targets: ["DrMaxNavigationDemoCore"]
        )
    ],
    dependencies: [
        .package(name: "swift-drmax-navigation", path: "../.."),
        .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.7.3")
    ],
    targets: [
        .target(
            name: "DrMaxNavigationDemoCore",
            dependencies: [
                .product(name: "DrMaxNavigation", package: "swift-drmax-navigation"),
                .product(name: "CasePaths", package: "swift-case-paths")
            ]
        )
    ]
)
