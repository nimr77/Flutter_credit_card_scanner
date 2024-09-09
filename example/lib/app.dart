import 'package:flutter/material.dart';
import 'package:flutter_credit_card_scanner/credit_card_scanner.dart';

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
