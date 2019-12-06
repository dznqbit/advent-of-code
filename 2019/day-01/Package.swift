// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "day-01",
    dependencies: [
      .package(url: "https://github.com/bow-swift/bow.git", from: "0.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "day-01",
            dependencies: [
              "Bow",
              "BowOptics"
            ]),
        .testTarget(
            name: "day-01Tests",
            dependencies: ["day-01"]),
    ]
)
