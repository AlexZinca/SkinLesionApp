import 'package:flutter/material.dart';
import 'package:my_camera/pages/intro_page.dart'; // Ensure this import points to the correct location of IntroPage in your project.

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool automaticLogin = true;
  bool biometricAuth = true;
  bool websitesRedirection = true;
  Color switchColor = Color.fromARGB(255, 94, 184, 209).withOpacity(0.7);

  final BoxDecoration loginButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 151, 199, 212).withOpacity(0.7),
        Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        spreadRadius: 0,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(
            16.0), // Add padding to the entire ListView
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: 0),
                  SwitchListTile(
                    title: Text(
                      'Automatic login',
                      style: TextStyle(fontSize: 15), // Smaller text size
                    ),
                    subtitle: Text(
                      'It is done when opening the application',
                      style: TextStyle(fontSize: 13), // Smaller text size
                    ),
                    value: automaticLogin,
                    onChanged: (bool value) {
                      setState(() {
                        automaticLogin = value;
                      });
                    },
                    activeColor: switchColor,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 2), // Adjusted content padding
                  ),
                  SwitchListTile(
                    title: Text(
                      'Biometric authorization',
                      style: TextStyle(fontSize: 15), // Smaller text size
                    ),
                    subtitle: Text(
                      'Face ID',
                      style: TextStyle(fontSize: 13), // Smaller text size
                    ),
                    value: biometricAuth,
                    onChanged: (bool value) {
                      setState(() {
                        biometricAuth = value;
                      });
                    },
                    activeColor: switchColor,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 0), // Adjusted content padding
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
                    // Add logic for about app here
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Increased space between list and button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IntroPage()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: loginButtonDecoration,
                child: Center(
                  // Center the text and icon
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('      LOGOUT',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)), // Smaller text size
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
