
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ScanResult {
  final String imageUrl;
  final String scanResult;
  final DateTime timestamp;

  ScanResult({required this.imageUrl, required this.scanResult, required this.timestamp});
}
List<dynamic> _transformListWithHeaders(List<ScanResult> results) {
  if (results.isEmpty) return [];

  List<dynamic> itemsWithHeaders = [];
  DateTime now = DateTime.now();
  String today = DateFormat('dd/MM/yyyy').format(now);
  String yesterday = DateFormat('dd/MM/yyyy').format(now.subtract(Duration(days: 1)));

  String? lastAddedHeader = null;

  for (var result in results) {
    String resultDate = DateFormat('dd/MM/yyyy').format(result.timestamp);
    String header;

    if (resultDate == today) {
      header = 'Today';
    } else if (resultDate == yesterday) {
      header = 'Yesterday';
    } else {
      header = DateFormat('EEEE, dd MMMM yyyy').format(result.timestamp);
    }

    // Ensure a header is added only once by comparing it to the last added header
    if (lastAddedHeader == null || lastAddedHeader != header) {
      itemsWithHeaders.add(header);
      lastAddedHeader = header; // Update the last added header
    }
    itemsWithHeaders.add(result);
  }

  return itemsWithHeaders;
}



Future<List<ScanResult>> fetchScanResults() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('scanResults')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true) // Fetch newer results first
      .get();

  return snapshot.docs.map((doc) {
    return ScanResult(
      imageUrl: doc['imageUrl'],
      scanResult: doc['scanResult'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }).toList();
}

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  late Future<List<ScanResult>> futureScanResults;
  bool sortByDay = false; // Add this line

  @override
  void initState() {
    super.initState();
    futureScanResults = fetchScanResults();
  }

  void toggleSortMethod() {
    setState(() {
      sortByDay = !sortByDay;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
        title: const Text('MEDICAL HISTORY',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: FutureBuilder<List<ScanResult>>(
        future: futureScanResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching results'));
          } else if (snapshot.hasData) {
            final itemsWithHeaders = _transformListWithHeaders(snapshot.data!);
            return Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
              child: ListView.builder(
                itemCount: itemsWithHeaders.length,
                itemBuilder: (context, index) {
                  final item = itemsWithHeaders[index];
                  if (item is String) { // When the item is a header
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        padding: const EdgeInsets.all(9.0),
                        constraints: BoxConstraints(maxWidth: 230, minWidth: 230), // Use constraints for width
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7), // Background color
                          borderRadius: BorderRadius.circular(20.0), // Rounded corners
                        ),
                        child: Text(
                          item,
                          textAlign: TextAlign.center, // Center the text
                          style: TextStyle(
                            color: Colors.white, // White text color for contrast
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    );
                  } else if (item is ScanResult) {
                    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp);
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      elevation: 2,
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Image.network(item.imageUrl),
                                ),
                              ),
                            );
                          },
                          child: Image.network(item.imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        title: Text(item.scanResult),
                        subtitle: Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp)}'),
                      ),
                    );
                  } else {
                    return SizedBox.shrink(); // This line should not be reached
                  }
                },
              ),
            );
          } else {
            // When no data is found
            return Center(child: Text('No results found'));
          }
        },
      ),
    );
  }
}