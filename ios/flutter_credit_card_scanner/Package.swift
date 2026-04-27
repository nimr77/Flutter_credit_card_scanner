// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_credit_card_scanner",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(name: "flutter-credit-card-scanner", type: .static, targets: ["flutter_credit_card_scanner"])
    ],
    targets: [
        .target(
            name: "flutter_credit_card_scanner",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
