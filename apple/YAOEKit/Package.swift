// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YAOEKit",
    // 包内只依赖 Foundation/Markdown，保持较低平台门槛以便命令行 `swift test`
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "YAOEKit", targets: ["YAOEKit"])],
    dependencies: [.package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.8.0")],
    targets: [
        .target(
            name: "YAOEKit",
            dependencies: [.product(name: "Markdown", package: "swift-markdown")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "YAOEKitTests",
            dependencies: ["YAOEKit"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
