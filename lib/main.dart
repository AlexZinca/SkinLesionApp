import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_camera/pages/intro_page.dart';
import 'package:my_camera/pages/blank_intro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Make sure Firebase is initialized
  final storage = FlutterSecureStorage();
  String? biometricEnabled = await storage.read(key: 'biometricAuth');
  bool useBiometric = biometricEnabled == 'true'; // Check if biometric is enabled

  runApp(MyApp(useBiometric: useBiometric));
}

class MyApp extends StatelessWidget {
  final bool useBiometric;

  const MyApp({super.key, required this.useBiometric});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: useBiometric ? BiometricLoginPage() : IntroPage(), // Conditionally load the initial page
    );
  }
}
