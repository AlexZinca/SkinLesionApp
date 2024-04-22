import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure Firebase is initialized in your project
import 'package:flutter/widgets.dart';
import 'package:my_camera/pages/intro_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final storage = FlutterSecureStorage();

  void _register() async {
    if (!EmailValidator.validate(emailController.text)) {
      _showDialog('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        usernameController.text.isEmpty) {
      _showDialog('Missing Fields', 'Please fill in all the fields.');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showDialog('Password Mismatch', 'The passwords do not match.');
      return;
    }

    try {
      // Using Firebase Authentication to register the user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        await storage.write(key: 'biometricPromptOnLogin', value: 'false');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IntroPage())).then((_) {
          // Ensure biometricPromptOnLogin is set to false when navigating back
          storage.write(key: 'biometricPromptOnLogin', value: 'false');
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during registration. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      }
      _showDialog('Registration Failed', errorMessage);
    } catch (e) {
      _showDialog('Error', 'An unexpected error occurred. Please try again.');
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
              child: Text('OK', style: TextStyle(color: Color.fromARGB(255, 94, 184, 209))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _confirmPasswordVisible = !_confirmPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    InputDecoration getInputDecoration(String hintText, IconData icon, {bool isObscure = false, VoidCallback? toggleVisibility}) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isObscure
            ? IconButton(
          icon: Icon(
              toggleVisibility == _togglePasswordVisibility ? (_passwordVisible ? Icons.visibility : Icons.visibility_off) : (_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
              color: Colors.grey
          ),
          onPressed: toggleVisibility,
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300)),
      );
    }

    final BoxDecoration textFieldDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );

    final BoxDecoration loginButtonDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [Color.fromARGB(255, 151, 199, 212).withOpacity(0.7), Color.fromARGB(255, 94, 184, 209).withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.4), spreadRadius: 0, blurRadius: 10, offset: Offset(0, 4)),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Positioned(
            top: -100, // Adjusted for top right alignment
            right: -40, // Adjusted for top right alignment
            child: CircleDecoration(
              diameter: 300,
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 151, 199, 212).withOpacity(0.7), Color.fromARGB(255, 94, 184, 209).withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            bottom: -120, // Adjusted for bottom alignment
            right: -160, // Adjusted for bottom alignment
            child: CircleDecoration(
              diameter: 400,
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 151, 199, 212).withOpacity(0.7), Color.fromARGB(255, 94, 184, 209).withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
           Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.14),  // Adjust the spacing
                  Text('Sign up', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),  // Adjust the spacing
                  Text('Create your account', style: TextStyle(fontSize: 15, color: Colors.grey)),
                  SizedBox(height: 40),  // Adjust the spacing
                  // TextField for username, email, password and confirm password
                  Container(
                    decoration: textFieldDecoration,
                    child: TextField(
                      controller: usernameController,
                      decoration: getInputDecoration('Username', Icons.person),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: textFieldDecoration,
                    child: TextField(
                      controller: emailController,
                      decoration: getInputDecoration('Email', Icons.email),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: textFieldDecoration,
                    child: TextField(
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      decoration: getInputDecoration('Password', Icons.lock, isObscure: true, toggleVisibility: _togglePasswordVisibility),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: textFieldDecoration,
                    child: TextField(
                      controller: confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: getInputDecoration('Confirm Password', Icons.lock, isObscure: true, toggleVisibility: _toggleConfirmPasswordVisibility),
                    ),
                  ),
                  SizedBox(height: 100),
                  // SIGN UP button
                  Center(
                    child: InkWell(
                      onTap: _register,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 120, vertical: 20),
                        decoration: loginButtonDecoration,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text('SIGN UP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 107),  // Adjust the spacing
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IntroPage())).then((_) {
                          // Ensure biometricPromptOnLogin is set to false when navigating back
                          storage.write(key: 'biometricPromptOnLogin', value: 'false');
                        });
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(color: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 80),  // Adjust the spacing
                ],
              ),
            ),
        ],
      ),
    ),
    );

  }
}


class CircleDecoration extends StatelessWidget {
  final double diameter;
  final LinearGradient gradient;

  const CircleDecoration({Key? key, required this.diameter, required this.gradient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
    );
  }
}
class RoundedDiagonalPathClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Clipper path implementation...
    return Path();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

