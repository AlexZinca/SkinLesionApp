import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:process_run/shell.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

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
  String disease = '';
  String diseaseR = '';
  double buttonsContainerHeight = 120.0;
  double containerHeight = 270.0;
  bool scanCompleted = false;  // State variable to track scan completion

  @override
  void initState() {
    super.initState();
    displayImagePath =
        widget.imagePath; // Initialize with the widget's imagePath
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceFolderImg = referenceRoot.child('images');

      final metadata = SettableMetadata(
        contentType: 'image/png',
        customMetadata: {'picked-file-path': imageFile.path},
      );

      Reference referenceImgToUpload = referenceFolderImg.child(fileName);

      UploadTask uploadTask =
      referenceImgToUpload.putData(await imageFile.readAsBytes(), metadata);
      await uploadTask.whenComplete(() => () async {});

      var x = (await referenceImgToUpload.getDownloadURL());
      return x;

      /*uploadTask.whenComplete(() => () async{

      });*/

      //return downloadUrl;
    } catch (e) {
      print(e);
    }

    return '';
  }

  Future<void> _saveScanResult(
      String imageUrl, String scanResult, String isCancerous) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('scanResults').add({
      'userId': userId,
      'imageUrl': imageUrl,
      'scanResult': scanResult,
      'isCancerous': isCancerous,
      'timestamp': FieldValue.serverTimestamp(),
    });
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

  Future<void> createAndSharePdf() async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(
      File(displayImagePath).readAsBytesSync(),
    );

    pdf.addPage(
        pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(image, width: 400, height: 300), // Adjust size as needed
                  pw.SizedBox(height: 20),
                  pw.Text('Diagnostic Result:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(disease, style: pw.TextStyle(fontSize: 16)),
                  pw.Text(diseaseR, style: pw.TextStyle(fontSize: 14)),
                ],
              );
            }
        )
    );

    // Save the document to a file
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Diagnosis.pdf');
      await file.writeAsBytes(await pdf.save());
      Share.shareFiles([file.path], text: 'Here is the diagnosis result.'); // Using share_plus to share the file
    } catch (e) {
      print("Error saving or sharing PDF: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    double buttonsContainerHeight = 120.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 69, 84, 162).withOpacity(0.7),
        title: const Text('CAPTURED IMAGE',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: buttonsContainerHeight + 94),
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
              height: containerHeight,
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
                child: isProcessing
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40),
                    Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        size: 50,
                        color: Color.fromARGB(255, 69, 84, 162).withOpacity(0.7)
                      ),
                    ),
                    SizedBox(height: 20), // Spacing between the animation and text
                    Text(
                      'Processing...',
                      style: TextStyle(
                          fontSize: 16,
                          color:Color.fromARGB(255, 69, 84, 162).withOpacity(0.7)),
                    )
                  ],
                )
                    : Column(
                  children: [
                    if (disease.isNotEmpty) ...[
                      Text(disease, style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text(diseaseR, style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 20),
                    ],
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
                    SizedBox(height: 21),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(
                          context,
                          icon: Icons.analytics,
                          label: 'Scan',
                          width: scanCompleted ? 170 : 360,
                          onPressed: () async {
                            setState(() {
                              isProcessing =
                              true; // Start the loading animation
                            });
                            try {
                              var uri =
                              // Uri.parse('http://192.168.1.128:5000/predict');
                              Uri.parse(
                                  'https://hello-mwr67lwjrq-ew.a.run.app/');
                              var request = http.MultipartRequest('POST', uri)
                                ..files.add(await http.MultipartFile.fromPath(
                                  'file',
                                  //widget.imagePath,
                                  displayImagePath,
                                ));
                              //var response = await http.get(uri);

                              var response = await http.Response.fromStream(
                                  await request.send());

                              if (response.statusCode == 200) {
                                var jsResponse = json.decode(response.body);
                                setState(() {
                                  scanCompleted = true;
                                  // other state updates
                                });
                                var messageValue =
                                jsResponse['data'].toString();

                                switch (messageValue) {
                                  case '0':
                                    disease =
                                    'Actinic keratoses and intraepithelial carcinoma / Bowen"s disease';
                                    diseaseR =
                                    'Considered to be precancerous';
                                    break; // The switch statement must be told to exit, or it will execute every case.
                                  case '1':
                                    disease = 'Basal cell carcinom';
                                    diseaseR =
                                    'Considered to be the most common form of skin cancer';
                                    break;
                                  case '2':
                                    disease = 'Benign keratosis';
                                    diseaseR = 'Not considered cancerous';
                                    break;
                                  case '3':
                                    disease = 'Dermatofibroma';
                                    diseaseR = 'Not considered cancerous';
                                    break;
                                  case '4':
                                    disease = 'Melanoma';
                                    diseaseR =
                                    'Considered to be the most serious form of skin cancer';
                                    break;
                                  case '5':
                                    disease = 'Melanocytic nevi';
                                    diseaseR = 'Not considered cancerous';
                                    break;
                                  case '6':
                                    disease = 'Vascular lesions';
                                    diseaseR = 'Not considered cancerous';
                                    break;
                                  default:
                                    disease = 'Not cancerous';
                                    diseaseR = "";
                                }
                                // Increase container height if there are results to show
                                if (disease.isNotEmpty) {
                                  containerHeight = 330.0;
                                } else {
                                  containerHeight =
                                  270.0; // Reset to default if no results
                                }

                                //var disease = _getDiseaseFromResponse(jsResponse['message'].toString());
                                String imageUrl = await _uploadImage(
                                    File(displayImagePath));
                                await _saveScanResult(
                                    imageUrl, disease, diseaseR);
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
                            } finally {
                              setState(() {
                                isProcessing = false; // Stop loading
                              });
                            }
                          },
                        ),
                        if (scanCompleted)
                          _buildButton(
                            context,
                            icon: Icons.share,
                            label: 'Share',
                            width: 170, // Smaller width for share button
                            onPressed: createAndSharePdf,
                          ),],),
                  ],
                ),
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
      width: width ?? MediaQuery.of(context).size.width * 0.8,
      // Use the width parameter or default to 80% of screen width
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 82, 95, 166).withOpacity(0.7),
            Color.fromARGB(255, 69, 84, 162).withOpacity(0.7)
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