import 'dart:io'; // For handling file operations
import 'package:camera/camera.dart'; // Camera package for taking pictures
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart'; // To save images in the gallery

// Add a new page for camera functionality
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Error initializing camera: $e';
      });
    }
  }

  // Capture an image and save it to the gallery
  Future<void> _captureImage() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final image = await _cameraController!.takePicture();
      await GallerySaver.saveImage(image.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture saved to gallery')),
      );
    } catch (e) {
      setState(() {
        _error = 'Error capturing image: $e';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
        backgroundColor: Colors.blue,
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: _captureImage,
                      child: Icon(Icons.camera_alt),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: _error.isNotEmpty
                  ? Text(_error)
                  : CircularProgressIndicator(),
            ),
    );
  }
}
