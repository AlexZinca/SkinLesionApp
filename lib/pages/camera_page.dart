import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_camera/pages/display_image.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final firstCamera = cameras.first;
      _controller = CameraController(firstCamera, ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      }).catchError((e) {
        print(e); // Handle any errors during camera initialization
      });
    } else {
      print('No cameras available');
    }
  }


  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }
/*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _requestCameraPermission();
      }
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          _buildControlBar(context),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 251, 254),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, -6),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Capture',
                  onPressed: () async {
                    try {
                      await _initializeControllerFuture;
                      final image = await _controller!.takePicture();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DisplayPictureScreen(imagePath: image.path),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
                _buildButton(
                  context,
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: () async {
                    try {
                      final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DisplayPictureScreen(imagePath: image.path),
                          ),
                        );
                      } else {
                        // Handle the case where the user cancels the picker.
                        print('No image selected.');
                      }
                    } catch (e) {
                      // Print or display any errors.
                      print('Error occurred: $e');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onPressed}) {
    double buttonSize = 40.0;
    double borderRadius = 18;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      decoration: loginButtonDecoration.copyWith(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: buttonSize),
            SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: buttonSize / 3),
            ),
          ],
        ),
      ),
    );
  }
}

final BoxDecoration loginButtonDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color.fromARGB(255, 151, 199, 212).withOpacity(0.7),
      Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      spreadRadius: 0,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ],
);
