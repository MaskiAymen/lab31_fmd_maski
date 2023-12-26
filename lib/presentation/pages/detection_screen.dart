import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';


class DetectionScreen extends StatefulWidget {
  final File image;
  final List<dynamic>? prediction;

  DetectionScreen({required this.image, required this.prediction});

  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  late CameraController _controller;
  late CameraImage _cameraImage;
  bool _isDetecting = false;
  String _detectedLabel = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    CameraDescription frontCamera = cameras.first;

    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
        break;
      }
    }

    _controller = CameraController(frontCamera, ResolutionPreset.high);
    await _controller.initialize();

    if (mounted) {
      setState(() {});
    }

    _controller.startImageStream((image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _cameraImage = image;
        _detectLiveImage();
      }
    });
  }

  Future<void> _detectLiveImage() async {
    try {
      if (_cameraImage != null) {
        var prediction = await Tflite.runModelOnFrame(
          bytesList: _cameraImage.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: _cameraImage.height,
          imageWidth: _cameraImage.width,
          numResults: 2,
          threshold: 0.6,
          imageMean: 127.5,
          imageStd: 127.5,
        );

        if (mounted) {
          setState(() {
            if (prediction != null && prediction.isNotEmpty) {
              _detectedLabel = prediction[0]['label'].toString().substring(2);
            } else {
              _detectedLabel = 'No prediction';
            }
          });
        }
      }
    } catch (e) {
      print('Error during prediction: $e');
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _toggleCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription currentCamera = _controller.description;
    final CameraDescription newCamera = cameras.firstWhere(
          (camera) => camera.lensDirection != currentCamera.lensDirection,
      orElse: () => cameras.first,
    );

    if (_controller != null) {
      await _controller.dispose();
    }

    _controller = CameraController(newCamera, ResolutionPreset.high);
    await _controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.stopImageStream();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detection',
          style: GoogleFonts.roboto(),
        ),
      ),
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? Container(
            height: double.infinity,
            child: Stack(
              children: [
                CameraPreview(_controller),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.teal,
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Detected: $_detectedLabel',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
              : Container(),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _toggleCamera,
                child: Icon(Icons.switch_camera),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 220,
                    padding: EdgeInsets.all(15),
                    child: Image.file(widget.image),
                  ),
                  SizedBox(height: 10),
                  if (widget.prediction != null && widget.prediction!.isNotEmpty)
                    Text(
                      widget.prediction![0]['label'].toString().substring(2),
                      style: GoogleFonts.roboto(fontSize: 18),
                    ),
                  if (widget.prediction != null && widget.prediction!.isNotEmpty)
                    Text(
                      'Confidence: ' + widget.prediction![0]['confidence'].toString(),
                      style: GoogleFonts.roboto(fontSize: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}