
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

Future<void> saveScanResult(File imageFile, String scanResult) async {
  try {
    // Assuming you have a user ID to associate the scan with
    String userId = "your_user_id";

    // Upload image to Firebase Storage
    String fileName = "scans/${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg";
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(imageFile);

    // Get image URL
    final imageUrl = await ref.getDownloadURL();

    // Save scan result and image URL to Firestore
    FirebaseFirestore.instance.collection('medicalHistory').add({
      'userId': userId,
      'imageUrl': imageUrl,
      'scanResult': scanResult,
      'timestamp': DateTime.now(),
    });

  } catch (e) {
    print(e);
  }
}



class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medical History")),
      body: StreamBuilder(
        stream: _firestore.collection('medicalHistory')
            .where('userId', isEqualTo: "your_user_id")
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(data['imageUrl'], width: 100, fit: BoxFit.cover),
                title: Text(data['scanResult']),
                subtitle: Text(data['timestamp'].toDate().toString()),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
