import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_camera/pages/intro_page.dart';

import 'camera_page.dart'; // Ensure this import is correct.

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool automaticLogin = true;
  bool biometricAuth = true;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  Color switchColor = Color.fromARGB(255, 94, 184, 209).withOpacity(0.7);

  @override
  void initState() {
    super.initState();
    _loadAutomaticLoginStatus();
    _loadBiometricAuthStatus();
  }

  Future<void> _loadAutomaticLoginStatus() async {
    String? remember = await storage.read(key: 'rememberCredentials');
    setState(() {
      automaticLogin = remember == 'true';
    });
  }

  Future<void> _loadBiometricAuthStatus() async {
    String? biometric = await storage.read(key: 'biometricAuth');
    setState(() {
      biometricAuth = biometric == 'true';
    });
  }

  Future<void> _toggleAutomaticLogin(bool value) async {
    setState(() {
      automaticLogin = value;
    });
    await storage.write(
        key: 'rememberCredentials', value: automaticLogin ? 'true' : 'false');
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    setState(() {
      biometricAuth = value;
    });
    await storage.write(
        key: 'biometricAuth', value: biometricAuth ? 'true' : 'false');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SwitchListTile(
                    title:
                        Text('Automatic login', style: TextStyle(fontSize: 15)),
                    subtitle: Text('It is done when opening the application',
                        style: TextStyle(fontSize: 13)),
                    value: automaticLogin,
                    onChanged: _toggleAutomaticLogin,
                    activeColor: switchColor,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                  ),
                  SwitchListTile(
                    title: Text('Biometric authorization',
                        style: TextStyle(fontSize: 15)),
                    subtitle: Text('Face ID', style: TextStyle(fontSize: 13)),
                    value: biometricAuth,
                    onChanged: _toggleBiometricAuth,
                    activeColor: switchColor,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.0, vertical: 0),
                  ),
                  ListTile(
                    title: Text(
                      'Feedback',
                      style: TextStyle(fontSize: 15), // Smaller text size
                    ),
                    subtitle: Text(
                      'Send us your opinion about the application',
                      style: TextStyle(fontSize: 13), // Smaller text size
                    ),
                    // Add logic for feedback here
                  ),
                  ListTile(
                    title: Text(
                      'About app',
                      style: TextStyle(fontSize: 15), // Smaller text size
                    ),
                    subtitle: Text(
                      'Learn more about the application',
                      style: TextStyle(fontSize: 13), // Smaller text size
                    ),
                  ), // Your other ListTiles for Feedback and About app...
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () async {
                if (!automaticLogin) {
                  await storage.delete(key: 'email');
                  await storage.delete(key: 'password');
                }
                await storage.write(key: 'loggingOut', value: 'true');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => IntroPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: loginButtonDecoration,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('LOGOUT',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
