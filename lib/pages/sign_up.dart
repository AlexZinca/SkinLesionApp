import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:my_camera/pages/intro_page.dart';
import '../services/auth.dart';

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

  void _register() async {


    if (!EmailValidator.validate(emailController.text)) {
      _showDialog('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty || usernameController.text.isEmpty) {
      _showDialog('Missing Fields', 'Please fill in all the fields.');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showDialog('Password Mismatch', 'The passwords do not match.');
      return;
    }

    var user = await AuthService().registerWithEmailAndPassword(
        emailController.text, passwordController.text);
    if (user != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()));
    } else {
      _showDialog('Registration Failed', 'An error occurred during registration. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    InputDecoration getInputDecoration(String hintText, IconData icon, {bool isObscure = false, VoidCallback? toggleVisibility}) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isObscure
            ? IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
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
      body: Stack(
        children: [
          Positioned(
            top: -63,
            right: -140,
            child: Transform.rotate(
              angle: 2.4,
              child: ClipPath(
                clipper: RoundedDiagonalPathClipper(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.1,
                  height: MediaQuery.of(context).size.height * 0.7,
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
          SingleChildScrollView(  // Allows the column to be scrollable, preventing overflow
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),  // Adjust the spacing
                  Text('Sign up', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),  // Adjust the spacing
                  Text('Create your account', style: TextStyle(fontSize: 15, color: Colors.grey)),
                  SizedBox(height: 30),  // Adjust the spacing
                  // TextField for username, email, password and confirm password
                  Container(
                    decoration: textFieldDecoration,
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: getInputDecoration('Username', Icons.person),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: textFieldDecoration,
                    child: TextField(
                      controller: emailController,
                      decoration: getInputDecoration('Email', Icons.email),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: textFieldDecoration,
                    child: TextField(
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      decoration: getInputDecoration('Password', Icons.lock, isObscure: true, toggleVisibility: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      }),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: textFieldDecoration,
                    child: TextField(
                      controller: confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: getInputDecoration('Confirm Password', Icons.lock, isObscure: true, toggleVisibility: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      }),
                    ),
                  ),
                  SizedBox(height: 30),
                  // SIGN UP button
                  Center(
                    child: InkWell(
                      onTap: _register,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 44, vertical: 20),
                        decoration: loginButtonDecoration,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('SIGN UP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 112),  // Adjust the spacing
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()));
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
          ),
        ],
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

