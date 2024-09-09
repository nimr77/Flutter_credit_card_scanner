## CameraScannerWidgetCamera

**Description:**

This widget provides a camera preview that scans for credit card information using Google ML Kit Text Recognition. Once a credit card is detected in the frame, it extracts the card number, holder name, and expiration date. 

```dart
CameraScannerWidgetCamera (

    onScan:(ctx,value){},
    loadingHolder: CircularProgressIndicator(),
    onNoCamera: (){
        //error message
    }
)
```

**Demo:**

[cameraScannerWidgetCameraUrl]


**Input Parameters:**

* **`onScan`** (required): A callback function that receives the `BuildContext` and a `CreditCardModel` object containing the extracted credit card information (number, holder name, expiration month, expiration year)  when a card is scanned successfully. 
* **`loadingHolder`** (required): A widget to display while the camera is initializing. 
* **`onNoCamera`** (required): A callback function that is called if no camera is available on the device.
* **`aspectRatio`** (optional): The aspect ratio of the camera preview. Defaults to the aspect ratio of the device screen.

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
        CameraScannerWidgetCamera(
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

* This code provides a clear and concise documentation for the `CameraScannerWidgetCamera` widget, including its purpose, input parameters, and an example usage.
* The code is formatted using Markdown syntax, which is commonly used for writing README files on GitHub.
* The example demonstrates how to use the widget within a Flutter application to scan credit card information and display the extracted data.


[cameraScannerWidgetCameraUrl]: https://firebasestorage.googleapis.com/v0/b/project-one-06.appspot.com/o/WhatsApp%20Video%202024-09-09%20at%204.27.27%20PM.mp4?alt=media&token=e857f996-bca0-40f9-a57e-3f345e6f271e