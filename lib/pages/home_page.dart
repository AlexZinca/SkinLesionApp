import 'package:flutter/material.dart';
import 'package:my_camera/components/bottom_nav_bar.dart';
import 'package:my_camera/pages/camera_page.dart';
import 'package:my_camera/pages/main_page.dart';
import 'package:my_camera/pages/notifications_page.dart';
import 'package:my_camera/pages/settings_page.dart';
import 'package:my_camera/pages/user_Page.dart';
// ... other imports ...

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const MainPage(),
   // const UserPage(),
    const CameraPage(),
    //const NotificationsPage(),
    const SettingsPage(),
  ];

  final List<String> _pageTitles = [
    "DASHBOARD",
    //"ACCOUNT DETAILS",
    "ANALYSE",
    //"NOTIFICATIONS",
    "SETTINGS",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: navigateBottomBar,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
        title: Text(
          _pageTitles[_selectedIndex], // Set the title dynamically
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
