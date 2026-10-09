// swift-tools-version: 6.3
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "DrMaxNavigationDemo",
    platforms: [.iOS(.v17)],
    products: [
        .iOSApplication(
            name: "DrMaxNavigationDemo",
            targets: ["DrMaxNavigationDemo"],
            bundleIdentifier: "eu.drmax.DrMaxNavigation.Demo",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .map),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown]
        )
    ],
    dependencies: [
        .package(name: "swift-drmax-navigation", path: "../.."),
        .package(name: "DrMaxNavigationDemoCore", path: "../DrMaxNavigationDemoCore")
    ],
    targets: [
        .executableTarget(
            name: "DrMaxNavigationDemo",
            dependencies: [
                .product(name: "DrMaxNavigation", package: "swift-drmax-navigation"),
                .product(name: "DrMaxNavigationDemoCore", package: "DrMaxNavigationDemoCore")
            ]
        )
    ]
)
