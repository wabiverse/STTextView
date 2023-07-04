// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "STTextView",
  platforms: [.macOS(.v13)],
  products: [
    .library(
      name: "STTextView",
      targets: ["STTextView", "STTextViewUI"]
    ),
  ],
  targets: [
    .target(
      name: "STTextView"
    ),
    .target(
      name: "STTextViewUI",
      dependencies: ["STTextView"]
    ),
    .testTarget(
      name: "STTextViewTests",
      dependencies: ["STTextView"]
    ),
  ]
)
