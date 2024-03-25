import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatefulWidget {
  final Function(int)? onTabChange; // Add this line

  const MyBottomNavBar({Key? key, this.onTabChange})
      : super(key: key); // Modify this line

  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChange
        ?.call(index); // Add this line to notify the parent widget
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GNav(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 34), // Adjust padding here
        gap: 4, // Adjust gap between icons
        color: Colors.grey[400],
        activeColor: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
        mainAxisAlignment: MainAxisAlignment.center,
        onTabChange: (value) {
          setState(() {
            _selectedIndex = value;
          });
          if (widget.onTabChange != null) {
            widget.onTabChange!(value);
          }
        },
        tabs: [
          GButton(
            icon: Icons.home,
            iconColor: Colors.grey[400],
            onPressed: () => _onItemTapped(0),
          ),
          /*GButton(
            icon: Icons.person,
            iconColor: Colors.grey[400],
            onPressed: () => _onItemTapped(1),
          ),*/
          GButton(
            icon: Icons.code,
            iconColor: _selectedIndex == 2 ? Colors.red : Colors.white,
            leading: Container(
              margin: EdgeInsets.only(top: 4), // Adjust margin to move the icon up
              width: 80,
              height: 50,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: _selectedIndex == 1
                    ? Color.fromARGB(255, 94, 184, 209).withOpacity(0.7)
                    : Color.fromARGB(255, 170, 177, 179).withOpacity(0.7),
              ),
              child: Icon(
                Icons.code,
                color: Colors.white,
              ),
            ),
            onPressed: () => _onItemTapped(1),
          ),
          /*GButton(
            icon: Icons.notifications,
            iconColor: Colors.grey[400],
            onPressed: () => _onItemTapped(3),
          ),*/
          GButton(
            icon: Icons.widgets_rounded,
            iconColor: Colors.grey[400],
            onPressed: () => _onItemTapped(2),
          ),
        ],
      ),
    );
  }
}
