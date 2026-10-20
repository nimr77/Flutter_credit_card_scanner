// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "flutter_credit_card_scanner",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(name: "flutter-credit-card-scanner", targets: ["flutter_credit_card_scanner"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_credit_card_scanner",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
