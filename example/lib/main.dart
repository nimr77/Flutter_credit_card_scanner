import 'package:credit_card_scanner_example/app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyMaterialApp());
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: MyAppCreditCardScanner()),
    );
  }
}
