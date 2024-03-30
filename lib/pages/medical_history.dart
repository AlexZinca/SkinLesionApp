
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'diagnostic_detail_page.dart';

class ScanResult {
  final String imageUrl;
  final String scanResult;
  final DateTime timestamp;
  final String isCancerous;

  ScanResult({required this.imageUrl, required this.scanResult, required this.timestamp, required this.isCancerous});
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
      isCancerous: doc['isCancerous'],
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
                        constraints: BoxConstraints(maxWidth: 230, minWidth: 200), // Use constraints for width
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
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      elevation: 2,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Make widgets stretch to fill the card height
                          children: [
                            // Padding around the ClipRRect for the image
                            Padding(
                              padding: const EdgeInsets.all(0.0), // Adjust the padding as needed
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0), // Rounded corners for the image
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20.0), // Adjust this value to control the roundness of the corners
                                          child: Image.network(item.imageUrl, fit: BoxFit.cover),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(item.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            // Spacer between image and text/info button
                            // Spacer between image and text/info button
                            SizedBox(width: 20),
                            // Text information in the middle
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.scanResult,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${item.isCancerous}\n',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp)}',
                                            style: TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                        style: TextStyle(color: Colors.black), // Default text color
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Info button on the right
                      Padding(
                        padding: EdgeInsets.only(right: 20.0), // Adjust the padding value as needed
                        child: IconButton(
                          icon: Icon(Icons.info_outline, color: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiagnosticDetailPage(
                                  name: item.scanResult,
                                  //description: "Here you can put the detailed description related to this diagnostic.",
                                ),
                              ),
                            );
                          },
                        ),
                      ),


                          ],
                        ),
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