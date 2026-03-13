// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CmdEdit",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CmdEdit", targets: ["CmdEdit"])
    ],
    targets: [
        .executableTarget(
            name: "CmdEdit",
            path: "Sources/CmdEdit"
        )
    ]
)
