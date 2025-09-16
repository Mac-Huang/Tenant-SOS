// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TenantSOS",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TenantSOS",
            targets: ["TenantSOS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "TenantSOS",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                "Kingfisher"
            ]),
        .testTarget(
            name: "TenantSOSTests",
            dependencies: ["TenantSOS"]),
    ]
)