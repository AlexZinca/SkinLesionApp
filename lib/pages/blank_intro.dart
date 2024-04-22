import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_camera/pages/home_page.dart';
import 'package:my_camera/pages/intro_page.dart';

class BiometricLoginPage extends StatefulWidget {
  @override
  _BiometricLoginPageState createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => IntroPage()));
      }
    } catch (e) {
      print('Error using biometric authentication: $e');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => IntroPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
