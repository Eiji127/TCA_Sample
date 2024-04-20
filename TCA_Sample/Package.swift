// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCA_Sample",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "RepositoryListFeature", targets: ["RepositoryListFeature"]),
        .library(name: "Entity", targets: ["Entity"])
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.3.2"),
      .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "1.0.0"),
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.3"),
      .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.2"),
      .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.1.2"),
      .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
      .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
          name: "RepositoryListFeature",
          dependencies: [
            "Entity",
            .product(name: "CasePaths", package: "swift-case-paths"),
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            .product(name: "Dependencies", package: "swift-dependencies"),
            .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            .product(name: "SwiftUINavigationCore", package: "swiftui-navigation"),
          ]
        ),
        .target(
          name: "Entity"
        )
    ]
)
