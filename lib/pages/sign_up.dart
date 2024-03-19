import 'package:flutter/material.dart';
import 'package:my_camera/pages/intro_page.dart';

import '../services/auth.dart';

class SignUp extends StatelessWidget {
  SignUp({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    InputDecoration getInputDecoration(String hintText, IconData icon) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w300), // Make text slimmer
        prefixIcon: Icon(icon, color: Colors.grey),
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
            top: -63,
            right: -140,
            child: Transform.rotate(
              angle: 2.4, // Rotating by -30 degrees
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Text('Sign up',
                    style:
                    TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text('Create your account',
                    style: TextStyle(fontSize: 15, color: Colors.grey)),
                SizedBox(height: 32),
                // Email TextField with shadow
                Container(
                  decoration: textFieldDecoration,
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: getInputDecoration('Username', Icons.person),
                  ),
                ),
                SizedBox(height: 9),
                Container(
                  decoration: textFieldDecoration,
                  child: TextField(
                    controller: emailController,
                    decoration: getInputDecoration('Email', Icons.email),
                  ),
                ),
                SizedBox(height: 9),
                // Password TextField with shadow
                Container(
                  decoration: textFieldDecoration,
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: getInputDecoration('Password', Icons.lock),
                  ),
                ),

                SizedBox(height: 9),
                // Rewrite Password TextField with shadow
                Container(
                  decoration: textFieldDecoration,
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration:
                    getInputDecoration('Confirm Password', Icons.lock),
                  ),
                ),

                SizedBox(height: 60),
                Row(
                  children: [
                    Spacer(),
                    InkWell(
                      onTap: () async {
                        if (passwordController.text == confirmPasswordController.text) {
                          var user = await AuthService().registerWithEmailAndPassword(
                              emailController.text, passwordController.text);
                          if (user != null) {
                            // Navigate to the login page or wherever appropriate...
                            Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()));
                          } else {
                            // Handle registration failure...
                          }
                        } else {
                          // Handle password mismatch...
                        }
                      },
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 44, vertical: 20),
                        decoration: loginButtonDecoration,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('SIGN UP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -45,
            left: -50,
            child: Transform.rotate(
              angle: 6.4, // Rotating by -30 degrees
              child: ClipPath(
                clipper: RoundedDiagonalPathClipper(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IntroPage()));
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Login',
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
