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

  // Variables for tap-to-focus
  bool _showFocusCircle = false;
  double _focusX = 0;
  double _focusY = 0;
  CameraDescription? _frontCamera;
  CameraDescription? _backCamera;
  bool _isRearCameraSelected = true; // start with the rear camera
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _switchCamera() {
    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
      _controller = CameraController(
        _isRearCameraSelected ? (_backCamera!): _frontCamera!,
        ResolutionPreset.max,
      );
      _initializeControllerFuture = _controller!.initialize();
    });
  }

  void _toggleFlash() {
    setState(() {
      _isTorchOn = !_isTorchOn;
      _controller!.setFlashMode(
        _isTorchOn ? FlashMode.torch : FlashMode.off,
      );
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    // Assign the cameras to front and back camera
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        _frontCamera = camera;
      } else if (camera.lensDirection == CameraLensDirection.back) {
        _backCamera = camera;
      }
    }

    // Start with the back camera
    _controller = CameraController(
      _backCamera!,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      print(e); // Handle any errors during camera initialization
    });
  }



  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  void _onTap(TapUpDetails details) async {
    if (!_controller!.value.isInitialized) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

    // Calculate the position in the range of [0, 1]
    final Size previewSize = box.size;
    final double x = localPosition.dx / previewSize.width;
    final double y = localPosition.dy / previewSize.height;
    final Offset normalizedPosition = Offset(x, y);

    try {
      // Attempt to set focus and exposure.
      await _controller!.setFocusPoint(normalizedPosition);
      await _controller!.setExposurePoint(normalizedPosition);
    } catch (e) {
      // Handle or ignore the error
      print("Error setting focus or exposure point: $e");
    }

    // Show focus circle
    setState(() {
      _showFocusCircle = true;
      _focusX = localPosition.dx;
      _focusY = localPosition.dy;
    });

    // Hide the focus circle after a delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showFocusCircle = false);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // Obtain the size of the screen
    final Size screenSize = MediaQuery.of(context).size;
    // Assuming the CameraPreview is fullscreen. If not, adjust accordingly.
    final double screenWidth = screenSize.width;
    // Calculate the preview scale based on the screen and camera aspect ratios
    final double screenAspectRatio = screenWidth / screenSize.height;
    double? previewAspectRatio=1;
    if (_controller?.value.isInitialized ?? false) {
      previewAspectRatio = _controller!.value.aspectRatio;
    }
    //final double previewAspectRatio = _controller!.value.aspectRatio+200;
    // Adjust the preview height to maintain the preview aspect ratio
    final double previewHeight = screenWidth / previewAspectRatio;
    final double previewScale = screenSize.height / previewHeight;

    return Scaffold(
      body: GestureDetector(
          onTapUp: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localPosition = box.globalToLocal(details.globalPosition);
            // Adjust the tap position based on the preview scale
            final Offset scaledPosition = Offset(
              localPosition.dx / previewScale,
              localPosition.dy / previewScale,
            );
            _onTap(scaledPosition as TapUpDetails);
          },
        //onTapUp: _onTap, // Register tap event
          child: Stack(
            children:  [
          GestureDetector(
            onTapUp: _onTap, // Register tap event
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
              Positioned(
                top: 15.0, // Adjust the positioning as needed
                right: 15.0,
                child: Row(
                  children: [
                    if (_isRearCameraSelected)
                      _buildIconButton(
                        context,
                        icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                        onPressed: _toggleFlash,
                      ),
                    SizedBox(width: 15),
                    _buildIconButton(
                      context,
                      icon: Icons.flip_camera_ios,
                      onPressed: _switchCamera,
                    ),
                  ],
                ),
              ),
          _buildControlBar(context),
          if (_showFocusCircle)
            Positioned(
              left: _focusX - 20,
              top: _focusY - 20,
              child: Container(
                height: 50,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            ],
          ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          height: 110,
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
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Row(
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
                //SizedBox(height: 20),
               /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(
                      context,
                      icon: _isTorchOn ? Icons.flash_off : Icons.flash_on,
                      onPressed: _toggleFlash,
                    ),
                    _buildIconButton(
                      context,
                      icon: Icons.flip_camera_ios,
                      onPressed: _switchCamera,
                    ),
                    SizedBox(width: 150),
                  ],
                ),
*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 69, 84, 162).withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
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
      Color.fromARGB(255, 98, 110, 173).withOpacity(0.7),
      Color.fromARGB(255, 69, 84, 162).withOpacity(0.7),
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
