import 'package:flutter/material.dart';

import 'diagnostic_detail_page.dart';

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  final List<Map<String, String>> diagnostics = [
    {
      'id': '0',
      'name': 'Actinic keratoses and intraepithelial carcinoma / Bowen\'s disease',
    },
    {
      'id': '1',
      'name': 'Basal cell carcinoma',
    },
    {
      'id': '2',
      'name': 'Benign keratosis',
    },
    {
      'id': '3',
      'name': 'Dermatofibroma',
    },
    {
      'id': '4',
      'name': 'Melanoma',
    },
    {
      'id': '5',
      'name': 'Melanocytic nevi',
    },
    {
      'id': '6',
      'name': 'Vascular lesions',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 69, 84, 162).withOpacity(0.7),
        title: const Text('DIAGNOSTICS',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
              children: [
              SizedBox(height: 16), // Space before the list starts
          ...diagnostics.map((diagnostic) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiagnosticDetailPage(name: diagnostic['name']!),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Stack(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                    title: Text(
                      diagnostic['name']!,  // Ensure 'name' exists and is a String
                      style: TextStyle(
                        color: Colors.black54,  // Set text color to grey
                        //fontFamily: 'CustomFontFamily',  // Set the custom font family
                        fontSize: 16,  // Optionally set font size
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: DiagonalClipper(),
                      child: Container(
                        width: 80, // Adjust the width of the blue area here
                        color: Color.fromARGB(255, 69, 84, 162).withOpacity(0.7),
                        child: Padding(
                          padding: EdgeInsets.only(left: 30.0),
                          child: Icon(Icons.arrow_forward_ios, size: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
    ),
    ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  // Assume the same radius as the card's border radius
  final double borderRadius;

  DiagonalClipper({this.borderRadius = 16.0});

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Move to the point where the border radius on the top left begins
    path.moveTo(borderRadius+40, 0);
    // Create a line to the top right corner, minus the border radius to account for the rounded corner
    path.lineTo(size.width - borderRadius, 0);
    // Create an arc that mimics the top right rounded corner
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);
    // Create a line to the bottom right corner, minus the border radius to account for the rounded corner
    path.lineTo(size.width, size.height - borderRadius);
    // Create an arc that mimics the bottom right rounded corner
    path.quadraticBezierTo(size.width, size.height, size.width - borderRadius, size.height);
    // Create a line back to the start point, accounting for the bottom left corner's border radius
    path.lineTo(borderRadius, size.height);
    // Close the path. This will automatically create a straight line from the current point to the starting point
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
