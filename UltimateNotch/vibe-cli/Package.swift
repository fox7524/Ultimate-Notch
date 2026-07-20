// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "vibe-cli",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "vibe-cli",
            path: "."
        )
    ]
)
