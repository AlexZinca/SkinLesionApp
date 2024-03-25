import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:process_run/shell.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';

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

  //late String imagePath; // Local variable to hold the image path
  late String displayImagePath;

  @override
  void initState() {
    super.initState();
    displayImagePath =
        widget.imagePath; // Initialize with the widget's imagePath
  }


  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );

    if (croppedFile != null) {
      setState(() {
        displayImagePath = croppedFile.path; // Update the local variable
      });
    }
  }

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
            padding: EdgeInsets.only(bottom: buttonsContainerHeight +94),
            child: InteractiveViewer(
              panEnabled: false,
              boundaryMargin: EdgeInsets.all(0),
              minScale: 1,
              maxScale: 4,
              child: Image.file(
                File(displayImagePath), // Use displayImagePath here
                //File(widget.imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,

            child: Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, -6),
                      blurRadius: 6)
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(context,
                            icon: Icons.redo_rounded,
                            label: 'Retake',
                            width: 170,
                            onPressed: () => Navigator.of(context).pop()),
                        _buildButton(
                          context,
                          icon: Icons.crop,
                          label: 'Crop',
                          width: 170,
                          onPressed: _cropImage,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildButton(
                      context,
                      icon: Icons.analytics,
                      label: 'Scan',
                      width: 360,
                      onPressed: () async {
                        try {
                          var uri =
                          Uri.parse('http://172.20.10.2:5000/predict');
                          var request = http.MultipartRequest('POST', uri)
                            ..files.add(await http.MultipartFile.fromPath(
                              'file',
                              //widget.imagePath,
                                displayImagePath,
                            ));
                          print('a');
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
                            context: Navigator
                                .of(context)
                                .context,
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
              bottom: 20,
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
        required VoidCallback onPressed,
        double? width}) {
    // Optional width parameter
    return Container(
      width: width ?? MediaQuery
          .of(context)
          .size
          .width * 0.8,
      // Use the width parameter or default to 80% of screen width
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
          mainAxisAlignment: MainAxisAlignment.center,
          // Center the icon and text
          children: [
            Icon(icon, color: Colors.white, size: 40.0),
            SizedBox(width: 10),
            // A bit of spacing between the icon and text
            Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
            // Adjust font size as needed
          ],
        ),
      ),
    );
  }
}
