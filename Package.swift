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
    package.targets += [.binaryTarget(name: "skip", url: "https://github.com/vindhyadatascience/skipstone/releases/download/1.9.19-vds.5/skip-macos.zip", checksum: "de6b2bf198f4167ed7ece09955c4cd6e675bf3bb180efa1c4afc85cf9d29532a")]
    #elseif os(Linux)
    package.targets += [.binaryTarget(name: "skip", url: "https://github.com/vindhyadatascience/skipstone/releases/download/1.9.19-vds.5/skip-linux.zip", checksum: "f42c46fa2cdb33d1dbf301fe0b69b057295dee76cd9e204870ffe68fded0be4c")]
    #else
    package.dependencies += [.package(url: "https://github.com/vindhyadatascience/skipstone.git", revision: "ec9bad48a4153314236d6cd77636fa3c010bcdcf")]
    package.targets += [.executableTarget(name: "skip", dependencies: [.product(name: "SkipBuild", package: "skipstone")])]
    #endif
}

