## CameraScannerWidget

**Description:**

This widget provides a camera preview that scans for credit card information using Google ML Kit Text Recognition. Once a credit card is detected in the frame, it extracts the card number, holder name, and expiration date. 

```dart
CameraScannerWidget (

    onScan:(ctx,value){},
    loadingHolder: CircularProgressIndicator(),
    onNoCamera: (){
        //error message
    }
)
```

**Demo:**
Camera scanning video record


https://github.com/user-attachments/assets/ff6e818c-a65c-4bff-bb95-cbaef2368a23




**Input Parameters:**

* **`onScan`** (required): A callback function that receives the `BuildContext` and a `CreditCardModel` object containing the extracted credit card information (number, holder name, expiration month, expiration year)  when a card is scanned successfully. 
* **`loadingHolder`** (required): A widget to display while the camera is initializing. 
* **`onNoCamera`** (required): A callback function that is called if no camera is available on the device.
* **`aspectRatio`** (optional): The aspect ratio of the camera preview. Defaults to the aspect ratio of the device screen.
* **`cardNumber`** (optional): Whether to scan for the card number. Defaults to true.
* **`cardHolder`** (optional): Whether to scan for the card holder's name. Defaults to true.
* **`cardExpiryDate`** (optional): Whether to scan for the card's expiry date. Defaults to true.

**Implementations for Android and iOS:**

For Android:

1. Change the minimum Android sdk version to 21 (or higher) in your android/app/build.gradle file:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // ... other configurations
    }
}
```

2. Update your `android/app/src/main/AndroidManifest.xml` file to include camera permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.your_app_name">
    
    <uses-permission android:name="android.permission.CAMERA" />
    
</manifest>
```

For iOS:

1. Update your `ios/Runner/Info.plist` file to include camera usage description:

```plist
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera to scan credit cards.</string>
```

2. Add the following to your `ios/Podfile`:

```Podfile
platform :ios, '13.0'
```


Run `pod install` in the `ios` directory.

For both platforms, make sure to add the following dependencies to your `pubspec.yaml`:


Note: If you encounter an error with iOS, please check the Google ML Kit configuration at this link: https://pub.dev/packages/google_ml_kit


After adding these configurations, you can use the `CameraScannerWidget` in your Flutter app as shown in the example usage. The widget will handle the camera preview and ML Kit text recognition to scan credit cards on both Android and iOS platforms.

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
**Explanation:**

* This code provides a clear and concise documentation for the `CameraScannerWidget` widget, including its purpose, input parameters, and an example usage.
* The code is formatted using Markdown syntax, which is commonly used for writing README files on GitHub.
* The example demonstrates how to use the widget within a Flutter application to scan credit card information and display the extracted data.


