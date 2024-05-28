import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 10),
          NotificationCard(
            title: 'Centrul de consiliere și orientare în cariera',
            subtitle:
            'CCOC este dedicat exclusiv sprijinirii studentilor în explorarea și realizarea obiectivelor profesionale.',
            date: '21.02.2024, 12:38',
            link: 'bit.ly/4L9p1Hm',
          ),
          SizedBox(height: 2), // Adjusted space between cards
          NotificationCard(
            title: 'Invitație gratuită NO MA DE - 24 februarie',
            subtitle:
            'Complexul Favorit renaste...Pe 24 Februarie, la K2 Alpin, te așteaptă o seară de dans și distracție alături de un line-up de excepție.',
            date: '20.02.2024, 16:06',
            link: 'bit.ly/L4gciXXQ',
          ),
          // Add more NotificationCard widgets as needed
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String link;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 5.0), // Adjusted margin
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 69, 84, 162).withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications, color: Colors.white, size: 20.0),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.2, // smaller font size
                    )),
                SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(color: Colors.black, fontSize: 12.2)), // smaller font size
                SizedBox(height: 3),
                Text(date,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 10, // smaller font size
                    )),
                SizedBox(height: 1),
                Text(link,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 10, // smaller font size
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
