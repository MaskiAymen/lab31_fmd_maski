import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late CameraController _cameraController;
  bool isDetecting = false;
  List? _output;
  bool isLoadingModel = true;

  @override
  void initState() {
    super.initState();
    initModel();
    initCamera();
  }

  Future<void> initModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model.tflite',
        labels: 'assets/labels.txt',
      );
      setState(() {
        isLoadingModel = false;
      });
    } catch (e) {
      print('Failed to load model: $e');
      // Handle model loading failure
    }
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    //final firstCamera = cameras.first;

    _cameraController = CameraController(
      cameras.last,
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();

    _cameraController.startImageStream((CameraImage image) {
      if (!isDetecting) {
        isDetecting = true;
        detectImage(image);
      }
    });
  }

  Future<void> detectImage(CameraImage image) async {
    var prediction = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      numResults: 2,
      threshold: 0.6,
    );

    setState(() {
      _output = prediction!;
      isDetecting = false;
    });
  }

  void takePhoto() async {
    if (_cameraController.value.isInitialized) {
      XFile? image = await _cameraController.takePicture();
      if (image != null) {
        detectImage(File(image.path).readAsBytesSync() as CameraImage);
      }
    }
  }

  Widget buildOutputContainer(String text) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.black,
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget buildDetectionResults() {
    if (_output != null && _output!.isNotEmpty) {
      return Column(
        children: [
          buildOutputContainer(
            'Detect: ${_output![0]['label'].toString().substring(2)}',
          ),
          buildOutputContainer(
            'Confidence: ${(_output![0]['confidence']).toString()}',
          ),
        ],
      );
    } else {
      return Container(); // Empty container if there are no detection results
    }
  }

  @override
  void dispose() {
    _cameraController.stopImageStream();
    _cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          if (isLoadingModel)
            Center(
              child: CircularProgressIndicator(),
            ),
          buildDetectionResults(), // Display detection results
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: takePhoto,
        child: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
