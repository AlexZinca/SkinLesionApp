import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:process_run/shell.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class NativeBridge {
  static const platform = MethodChannel('com.yourcompany/native');

  static Future<String> executePythonScript() async {
    try {
      final String result = await platform.invokeMethod('executePythonScript');
      return result;
    } on PlatformException catch (e) {
      return "Failed to Execute Python Script: '${e.message}'.";
    }
  }
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String scriptOutput = '';
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final double buttonsContainerHeight = 120.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
        title: const Text('CAPTURED IMAGE',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: buttonsContainerHeight + 80),
            child: InteractiveViewer(
              panEnabled: false,
              boundaryMargin: EdgeInsets.all(0),
              minScale: 1,
              maxScale: 4,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 140,
            child: Container(
              height: buttonsContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, -6),
                      blurRadius: 6)
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(context,
                        icon: Icons.redo_rounded,
                        label: 'Retake',
                        onPressed: () => Navigator.of(context).pop()),
                    _buildButton(
                      context,
                      icon: Icons.analytics,
                      label: 'Scan',
                      onPressed: () async {
                        try {
                          var uri =
                          Uri.parse('http://172.20.10.2:5000/predict');
                          var request = http.MultipartRequest('POST', uri)
                            ..files.add(await http.MultipartFile.fromPath(
                              'file',
                              widget.imagePath,
                            ));

                          var response = await http.Response.fromStream(
                              await request.send());

                          if (response.statusCode == 200) {
                            var jsResponse = json.decode(response.body);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                var messageValue =
                                jsResponse['message'].toString();
                                var disease = '';
                                switch (messageValue) {
                                  case '0':
                                    disease =
                                    'Actinic keratoses and intraepithelial carcinoma / Bowen"s disease\n Considered to be precancerous';
                                    break; // The switch statement must be told to exit, or it will execute every case.
                                  case '1':
                                    disease =
                                    'Basal cell carcinom\nConsidered to be the most common form of skin cancer';
                                    break;
                                  case '2':
                                    disease =
                                    'Benign keratosis\nNot considered cancerous ';
                                    break;
                                  case '3':
                                    disease =
                                    'Dermatofibroma\nNot considered cancerous';
                                    break;
                                  case '4':
                                    disease =
                                    'Melanoma\nConsidered to be the most serious form of skin cancer';
                                    break;
                                  case '5':
                                    disease =
                                    'Melanocytic nevi\nNot considered cancerous';
                                    break;
                                  case '6':
                                    disease =
                                    'Vascular lesions\nNot considered cancerous';
                                    break;
                                  default:
                                    disease = 'Not cancerous';
                                }
                                return AlertDialog(
                                  title: const Text('Script Result'),
                                  content: SingleChildScrollView(
                                    child: Text(disease),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            throw Exception('Failed to load prediction');
                          }
                        } catch (e) {
                          final errorMessage = e.toString();
                          print(errorMessage);
                          showDialog(
                            context: Navigator.of(context).context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: SingleChildScrollView(
                                  child: Text(errorMessage),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isProcessing || scriptOutput.isNotEmpty)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(8.0),
                child: Text(
                  isProcessing ? 'Processing...' : scriptOutput,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onPressed}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 151, 199, 212).withOpacity(0.7),
            Color.fromARGB(255, 94, 184, 209).withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 40.0),
            SizedBox(width: 20),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 13.33)),
          ],
        ),
      ),
    );
  }
}