import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_camera/pages/home_page.dart';
import 'package:my_camera/pages/sign_up.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../services/auth.dart';

class IntroPage extends StatefulWidget {
  IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool _passwordVisible = false;
  bool rememberCredentials = false;
  final storage = FlutterSecureStorage();
  bool biometricAuth = false;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
    _loadBiometricAuthStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserCredentials();
    // Call this again in case settings changed while this page wasn't visible
  }

  Future<void> _loadBiometricAuthStatus() async {
    String? biometricAuthEnabled = await storage.read(key: 'biometricAuth');
    setState(() {
      biometricAuth = biometricAuthEnabled == 'true';
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    var localAuth = LocalAuthentication();
    bool didAuthenticate = false;

    try {
      didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Retrieve credentials only after successful authentication
        String? userEmail = await storage.read(key: 'userEmail');
        String? userPassword = await storage.read(key: 'userPassword');

        if (userEmail != null && userPassword != null) {
          // Autofill the credentials
          setState(() {
            emailController.text = userEmail;
            passwordController.text = userPassword;
          });

          // Optionally, you can directly log the user in or wait for them to press a button
          // Here, we invoke the login directly
          _login(userEmail, userPassword);
        } else {
          // Handle the case where no credentials are available
          _showNoCredentialsDialog();
        }
      }
    } catch (e) {
      print("Error during authentication: $e");
    }
  }

  Future<void> _login(String email, String password) async {
    try {
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (authResult.user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void _showNoCredentialsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Credentials'),
        content: Text('No saved credentials found. Please log in manually.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserCredentials() async {
    final storage = FlutterSecureStorage();

    // Load general remember credentials preference.
    String? remember = await storage.read(key: 'rememberCredentials');
    bool shouldRemember = remember == 'true';

    // Update the rememberCredentials state without affecting text fields directly.
    setState(() {
      rememberCredentials = shouldRemember;
    });

    // Only proceed to autofill credentials if coming from a logout with 'Automatic login' enabled.
    String? fromLogout = await storage.read(key: 'loggingOut');
    if (fromLogout == 'true') {
      await storage.delete(
          key: 'loggingOut'); // Clear the 'loggingOut' flag after checking.

      if (shouldRemember) {
        // Autofill credentials only if they should be remembered.
        String? userEmail = await storage.read(key: 'userEmail');
        String? userPassword = await storage.read(key: 'userPassword');

        if (userEmail != null && userPassword != null) {
          setState(() {
            emailController.text = userEmail;
            passwordController.text = userPassword;
          });
        }
      }
    }
  }

  Future<void> _rememberUserCredentials() async {
    if (rememberCredentials) {
      await storage.write(key: 'userEmail', value: emailController.text);
      await storage.write(key: 'userPassword', value: passwordController.text);
    } else {
      await storage.delete(key: 'userEmail');
      await storage.delete(key: 'userPassword');
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration getInputDecoration(String hintText, IconData icon,
        {Widget? suffixIcon}) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w300), // Make text slimmer
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );
    }

    // BoxDecoration with shadow for text fields
    BoxDecoration textFieldDecoration = BoxDecoration(
      color: Colors.white, // Background color
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 6,
          offset: Offset(0, 2), // changes position of shadow
        ),
      ],
    );

    // Original BoxDecoration for the login button remains unchanged
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Transform.rotate(
              angle: 2.4, // Rotating by -30 degrees
              child: ClipPath(
                clipper: RoundedDiagonalPathClipper(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                        Color.fromARGB(255, 110, 196, 219).withOpacity(0.7),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.27),
                Text('Login',
                    style:
                        TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text('Please sign in to continue',
                    style: TextStyle(fontSize: 15, color: Colors.grey)),
                SizedBox(height: 40),
                // Email TextField with shadow
                Container(
                  decoration: textFieldDecoration,
                  child: TextField(
                    controller: emailController, // TextInputType.emailAddress,
                    decoration: getInputDecoration('Email', Icons.person),
                  ),
                ),
                SizedBox(height: 14),
                // Password TextField with shadow
                Container(
                  decoration: textFieldDecoration,
                  child: TextField(
                    controller: passwordController,
                    obscureText: !_passwordVisible,
                    decoration: getInputDecoration(
                      'Password',
                      Icons.lock,
                      suffixIcon: Transform.translate(
                        offset: Offset(
                            -10, 0), // Shifts the icon 10 pixels to the left
                        child: IconButton(
                          icon: Icon(
                            // Toggle the icon based on password visibility
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            rememberCredentials = !rememberCredentials;
                          });
                          storage.write(
                              key: 'rememberCredentials',
                              value: rememberCredentials ? 'true' : 'false');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Checkbox(
                              value: rememberCredentials,
                              activeColor: Color.fromARGB(255, 94, 184, 209)
                                  .withOpacity(0.7),
                              onChanged: (bool? value) {
                                setState(() {
                                  rememberCredentials = value!;
                                });
                                storage.write(
                                    key: 'rememberCredentials',
                                    value:
                                        rememberCredentials ? 'true' : 'false');
                              },
                            ),
                            SizedBox(
                                width: 0), // Negative value to decrease space
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  rememberCredentials = !rememberCredentials;
                                });
                                storage.write(
                                    key: 'rememberCredentials',
                                    value:
                                        rememberCredentials ? 'true' : 'false');
                              },
                              child: Text(
                                "Remember credentials",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 94, 184, 209)
                                      .withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (emailController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error'),
                              content: Text(
                                  'Please enter your email address to reset your password.'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 94, 184, 209)
                                                  .withOpacity(0.7))),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        } else {
                          try {
                            await AuthService()
                                .sendPasswordResetEmail(emailController.text);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Email Sent'),
                                content: Text(
                                    'Check your email to reset your password.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                    255, 94, 184, 209)
                                                .withOpacity(0.7))),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          } catch (error) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Error'),
                                content: Text(error.toString()),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                    255, 94, 184, 209)
                                                .withOpacity(0.7))),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Forgot?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 94, 184, 209)
                              .withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Login failed'),
                                content: Text('Please enter both your email and password.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 94, 184, 209),
                                      ),
                                    ),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          try {
                            UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            if (authResult.user != null) {
                              if (rememberCredentials) {
                                await storage.write(key: 'userEmail', value: emailController.text);
                                await storage.write(key: 'userPassword', value: passwordController.text);
                              } else {
                                await storage.delete(key: 'userEmail');
                                await storage.delete(key: 'userPassword');
                              }
                              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                            }
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Login Failed'),
                                content: Text('An error occurred. Please try again.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 94, 184, 209),
                                      ),
                                    ),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 44, vertical: 20),
                          decoration: loginButtonDecoration,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('LOGIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                    biometricAuth ? SizedBox(width: 10) : SizedBox.shrink(), // Provide spacing only if biometricAuth is true
                    biometricAuth
                        ? Container(
                      height: 60, // Fixed height for circular button
                      width: 60,  // Fixed width for circular button
                      child: InkWell(
                        onTap: _authenticateWithBiometrics,
                        child: Center(
                          child: Container(
                            height: 60, // Adjust the size of the Face ID image
                            width: 60,
                            decoration: loginButtonDecoration.copyWith(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 151, 199, 212).withOpacity(0.7),
                                  Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ), // Ensures the image is circular
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0), // Padding to adjust the image inside the circular decoration
                              child: Image.asset(
                                'lib/images/faceid.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                        : SizedBox.shrink(),  // Don't display anything if biometricAuth is false
                  ],
                ),

              ],
            ),
          ),
          Positioned(
            bottom: -60,
            left: -50,
            child: Transform.rotate(
              angle: 6.8, // Rotating by -30 degrees
              child: ClipPath(
                clipper: RoundedDiagonalPathClipper(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.68,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        //Color.fromARGB(255, 210, 238, 245).withOpacity(0.7),
                        Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
                        Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            bottom: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignUp()));
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Don\'t have an account? ',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(
                        color:
                            Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedDiagonalPathClipper extends CustomClipper<Path> {
  double _getY(double x) {
    return x * 0.33;
  }

  @override
  Path getClip(Size size) {
    var roundnessFactor = 50.0;
    var equalization = 10.0;
    var path = Path();

    path.moveTo(0, roundnessFactor);
    path.lineTo(0, size.height - roundnessFactor);

    path.quadraticBezierTo(0, size.height, roundnessFactor, size.height);
    path.lineTo(size.width - roundnessFactor, size.height);

    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - roundnessFactor);

    path.lineTo(size.width, _getY(size.width) + roundnessFactor - equalization);
    path.quadraticBezierTo(
        size.width,
        _getY(size.width),
        size.width - roundnessFactor + equalization,
        _getY(size.width - roundnessFactor + equalization));

    path.lineTo(
        roundnessFactor + equalization, _getY(roundnessFactor + equalization));
    path.quadraticBezierTo(0, 0, 0, roundnessFactor + equalization);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
