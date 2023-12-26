import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lab31_fmd_maski/presentation/blocs/image_detection/image_detection_bloc.dart';
import 'package:lab31_fmd_maski/presentation/pages/home_page.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Tflite.loadModel(
    model: "assets/model.tflite",
    labels: "assets/label.txt",
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MASK DETECTOR',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => ImageDetectionBloc(),
        child: HomePage(),
      ),
    );
  }
}