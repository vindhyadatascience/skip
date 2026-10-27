// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "skip",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .macCatalyst(.v16),
    ],
    products: [
        .plugin(name: "skipstone", targets: ["skipstone"]),
        .plugin(name: "skiplink", targets: ["Create SkipLink"]),
        .plugin(name: "skiptranspile", targets: ["Skip Transpile"]),
        .library(name: "SkipDrive", targets: ["SkipDrive"]),
        .library(name: "SkipTest", targets: ["SkipTest"]),
    ],
    targets: [
        .plugin(name: "skipstone", capability: .buildTool(), dependencies: ["skip"], path: "Plugins/SkipPlugin"),
        .plugin(name: "Create SkipLink", capability: .command(intent: .custom(verb: "SkipLink", description: "Create local links to transpiled output"), permissions: [.writeToPackageDirectory(reason: "This command will create local links to the skipstone output for the specified package(s), enabling access to the transpiled Kotlin")]), dependencies: ["skip"], path: "Plugins/SkipLink"),
        .plugin(name: "Skip Transpile", capability: .command(intent: .custom(verb: "skip-transpile", description: "Transpile the Skip modules without building them"), permissions: [.writeToPackageDirectory(reason: "This command writes the transpiled output to the package's .build/plugins/outputs folder")]), dependencies: ["skip"], path: "Plugins/SkipTranspile"),
        .target(name: "SkipDrive", dependencies: ["skipstone", .target(name: "skip")]),
        .target(name: "SkipTest", dependencies: [.target(name: "SkipDrive", condition: .when(platforms: [.macOS, .macCatalyst, .linux]))]),
        .testTarget(name: "SkipTestTests", dependencies: ["SkipTest"]),
        .testTarget(name: "SkipDriveTests", dependencies: ["SkipDrive"]),
    ]
)

let env = Context.environment
if (env["SKIPLOCAL"] != nil || env["PWD"]?.hasSuffix("skipstone") == true) {
    package.dependencies += [.package(path: env["SKIPLOCAL"] ?? "../skipstone")]
    package.targets += [.executableTarget(name: "skip", dependencies: [.product(name: "SkipBuild", package: "skipstone")])]
} else {
    #if os(macOS)
    package.targets += [.binaryTarget(name: "skip", url: "https://github.com/vindhyadatascience/skipstone/releases/download/1.9.19-vds.7/skip-macos.zip", checksum: "63a16b6b31566b19532866dcbe16bfcea637d50cb20836c55966f57e4c4c523a")]
    #elseif os(Linux)
    package.targets += [.binaryTarget(name: "skip", url: "https://github.com/vindhyadatascience/skipstone/releases/download/1.9.19-vds.7/skip-linux.zip", checksum: "76b2d0cf5e6a46f2ffcc7d22725addfa3e53e623d9aa4a09521721b143d9ede1")]
    #else
    package.dependencies += [.package(url: "https://github.com/vindhyadatascience/skipstone.git", revision: "0fd3205bf8f66061bcc7ba966b6a32202970bdb2")]
    package.targets += [.executableTarget(name: "skip", dependencies: [.product(name: "SkipBuild", package: "skipstone")])]
    #endif
}

