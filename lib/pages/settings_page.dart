import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_camera/pages/intro_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'camera_page.dart'; // Ensure this import is correct.

// Inside an async method

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool automaticLogin = true;
  bool biometricAuth = false;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  Color switchColor = Color.fromARGB(255, 94, 184, 209).withOpacity(0.7);


  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadBiometricAuthStatus();
  }

  Future<void> _loadAutomaticLoginStatus() async {
    String? remember = await storage.read(key: 'rememberCredentials');
    setState(() {
      automaticLogin = remember == 'true';
    });
  }
  Future<void> _loadSettings() async {
    String? autoLogin = await storage.read(key: 'automaticLogin');
    setState(() {
      automaticLogin = autoLogin == 'true';
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
    await storage.write(key: 'automaticLogin', value: automaticLogin ? 'true' : 'false');
    if (!automaticLogin) {
      // Optionally clear credentials when automatic login is disabled
      await storage.delete(key: 'userEmail');
      await storage.delete(key: 'userPassword');
    }
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    setState(() {
      biometricAuth = value;
    });
    await storage.write(
        key: 'biometricAuth', value: biometricAuth ? 'true' : 'false');
  }

  Future<void> _sendEmail(String feedbackText) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'alexzinca@yahoo.com',
      query: 'subject=App Feedback&body=$feedbackText', // Use URL encoding for proper query parameter formatting
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.delete();
      // Handle post-deletion logic, like navigating to a sign-up screen.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => IntroPage()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors, for instance, show an error dialog
      _showDialog('Error', 'Failed to delete account: ${e.message}');
    }
  }


  Future<void> _showFeedbackDialog() async {
    final TextEditingController _feedbackController = TextEditingController();
    // Assuming `greenColor` and `textColor` are defined at the class level
    final Color greenColor = Color.fromARGB(255, 94, 184, 209).withOpacity(0.7);
    final Color textColor = Color.fromARGB(255, 145, 145, 145).withOpacity(0.7);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Ensure background color is white
          title: Text('Feedback'), // Use textColor for title
          content: SingleChildScrollView(
            child: TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                hintStyle: TextStyle(color: textColor.withOpacity(0.7),fontWeight: FontWeight.w400), // Lighter text color for hint
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: greenColor), // Green underline for focused border
                ),
              ),
              style: TextStyle(color: textColor), // Use textColor for input text
              cursorColor: greenColor, // Green cursor color
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: greenColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send', style: TextStyle(color: greenColor)),
              onPressed: () async {
                await _sendEmail(_feedbackController.text);
                Navigator.of(context).pop();
                // Optionally, handle the email sending logic here.
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _showAboutAppDialog() async {
    final Color greenColor = Color.fromARGB(255, 94, 184, 209).withOpacity(0.7); // Define your green color
    final textColor = Color.fromARGB(255, 145, 145, 145).withOpacity(0.7);
    // For dynamic version, use package_info package to fetch version.
    // For now, let's hardcode a version.
    String appVersion = '1.0.0'; // Example version

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About App'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This app is built using Flutter.', style: TextStyle(color: textColor)),
                SizedBox(height: 10),
                Text('Version: '+appVersion, style: TextStyle(color: textColor)),
                // Add more details here as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: greenColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    // Show confirmation dialog
    final textColor = Color.fromARGB(255, 145, 145, 145).withOpacity(0.7);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.',style: TextStyle(color: textColor) ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteAccount(); // Proceed with deleting the account
              },
            ),
          ],
        );
      },
    );
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
                    onTap: _showFeedbackDialog,
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
                    onTap: _showAboutAppDialog,
                  ), // Your other ListTiles for Feedback and About app...
                  ListTile(
                    title: Text(
                      'Delete Account',
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: Text(
                      'Permanently delete your account and data',
                      style: TextStyle(fontSize: 13),
                    ),
                    onTap: _showDeleteAccountDialog,
                  ),
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
                      Text('   LOGOUT',
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
