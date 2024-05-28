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
  bool _isAuthenticating = false; // This flag controls the display of the loading indicator.

  @override
  void initState() {
    super.initState();
    // Delay to show text before starting authentication.
    Future.delayed(Duration(milliseconds: 500), _authenticate);
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true; // Update the state to show the loading indicator.
      });
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'SkinSight',
              style: TextStyle(
                fontSize: 28.0,
                color: Color.fromARGB(255, 69, 84, 162).withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
