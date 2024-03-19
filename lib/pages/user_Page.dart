import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor:
              Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
              child: Text(
                'AZ',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Alexandru-Marian Zincă',
              style: theme.textTheme.titleLarge,
            ),
            Text(
              'alexandru.zinca@student.unitbv.ro',
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            DetailCard(
              title: 'Faculty',
              content:
              'Facultatea de Inginerie electrică și știința calculatoarelor',
            ),
            // ... other DetailCard widgets ...
          ],
        ),
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final String title;
  final String content;

  const DetailCard({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20), // Increased vertical padding for greater height
      margin: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 8), // Adjusted horizontal margin, reduced to 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjust as needed
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontSize: 14), // Updated deprecated text style
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 12), // Updated deprecated text style
            overflow: TextOverflow.ellipsis,
            maxLines:
            2, // Increased max lines for content to potentially take up more vertical space if needed
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
