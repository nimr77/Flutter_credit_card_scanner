## CameraScannerWidget

**Description:**

Introducing a cutting-edge Flutter package that harnesses the power of your device's camera to seamlessly scan and extract credit card information. This innovative solution leverages state-of-the-art machine learning technologies: Google ML Kit for Android devices and Apple Vision for iOS, ensuring optimal performance across platforms.

```dart
CameraScannerWidget (
    onScan: (ctx, value) {},
    loadingHolder: CircularProgressIndicator(),
    onNoCamera: () {
        // Handle camera unavailability
    }
)
```

**Demo:**
Witness the magic in action! 🎥✨

https://github.com/user-attachments/assets/ff6e818c-a65c-4bff-bb95-cbaef2368a23

**Key Features:**
- 📱 Cross-platform compatibility (iOS & Android)
- 🚀 Lightning-fast credit card recognition
- 🔒 Secure, on-device processing
- 🎨 Customizable UI elements

**Input Parameters:**

* **`onScan`** (required): Your gateway to extracted card data! This callback function receives the `BuildContext` and a `CreditCardModel` object containing the juicy details (number, holder name, expiration month, expiration year) when a card is successfully scanned. 
* **`loadingHolder`** (required): Keep your users engaged! Specify a widget to display during camera initialization. 
* **`onNoCamera`** (required): Gracefully handle camera unavailability with this callback function.
* **`aspectRatio`** (optional): Fine-tune your preview! Set the aspect ratio of the camera view (defaults to device screen ratio).
* **`cardNumber`** (optional): Toggle card number scanning (default: true).
* **`cardHolder`** (optional): Enable/disable cardholder name extraction (default: true).
* **`cardExpiryDate`** (optional): Control expiry date scanning (default: true).

**Platform-Specific Setup:**

Android Configuration:
1. Upgrade your Android experience! Update `android/app/build.gradle`:

android {
    defaultConfig {
        minSdkVersion 21
        // ... other configurations
    }
}


2. Grant camera access! Modify `android/app/src/main/AndroidManifest.xml`:


<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.your_app_name">
    
    <uses-permission android:name="android.permission.CAMERA" />
    
</manifest>


iOS Configuration:
1. Inform your users! Update `ios/Runner/Info.plist`:


<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan credit cards.</string>


2. Set the stage! Modify `ios/Podfile`:


platform :ios, '13.0'


Don't forget to run `pod install` in the `ios` directory!

**Example Usage:**

```dart
import 'package:flutter_credit_card_scanner/flutter_credit_card_scanner.dart';
import 'package:flutter/material.dart';

class MyAppCreditCardScanner extends StatefulWidget {
  const MyAppCreditCardScanner({super.key});

  @override
  State<MyAppCreditCardScanner> createState() => _MyAppCreditCardScannerState();
}

class _MyAppCreditCardScannerState extends State<MyAppCreditCardScanner> {
  CreditCardModel? cardModel;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraScannerWidget(
          onNoCamera: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('No camera found, please enable camera')));
          },
          onScan: (_, p1) {
            setState(() {
              cardModel = p1;
            });
          },
          loadingHolder: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        if (cardModel != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding: MediaQuery.of(context)
                  .padding
                  .add(const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    key: ValueKey(cardModel),
                    children: [
                      Text(cardModel!.number),
                      Text(cardModel!.holderName),
                      Text(cardModel!.expiryDate),
                    ]
                        .map((e) => Padding(
                            padding: const EdgeInsets.all(5),
                            child: Card(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: e,
                            ))))
                        .toList()),
              ),
            ),
          )
      ],
    );
  }
}
```

**Conclusion:**
Elevate your app's user experience with seamless credit card scanning! 🚀💳✨
