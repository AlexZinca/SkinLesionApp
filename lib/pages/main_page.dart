import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_camera/pages/clinics_page.dart';
import 'diagnostics_page.dart';
import 'firebase_options.dart';
import 'medical_history.dart';

//await Firebase.initializeApp(
//options: DefaultFirebaseOptions.currentPlatform,
//);

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 24; // Adjust for padding
    double imageHeight = width * 0.925; // Define image height relative to width
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0, left: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width,
                height: imageHeight, // Set the smaller height for the image
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'lib/images/1.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: widgetContainer(
                      icon: Icons.local_hospital_rounded,
                      text: 'CLINICS',
                      onTap: () {
                        // Navigate to DiagnosticsPage or another page as needed
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ClinicsPage()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: widgetContainer(
                      icon: Icons.photo_album_rounded,
                      text: 'DIAGNOSTICS',
                      onTap: () {
                        // Navigate to DiagnosticsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DiagnosticsPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedicalHistoryPage()),
                  );
                },
                child: Container(
                  height: 125,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, color: Colors.white, size: 40),
                      SizedBox(height: 4),
                      Text(
                        'MEDICAL HISTORY',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget widgetContainer({
    required IconData icon,
    required String text,
    required VoidCallback onTap, // Add this line
  }) {
    return InkWell( // Changed to InkWell for visual feedback on tap
      onTap: onTap, // Use the onTap parameter here
      borderRadius: BorderRadius.circular(20), // Match the container's borderRadius for the ripple effect
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
