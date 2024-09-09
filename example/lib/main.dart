import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card_scanner_example/app.dart';
import 'package:flutter_credit_card_scanner_example/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init FIREBASE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
