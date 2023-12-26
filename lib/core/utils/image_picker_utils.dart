import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../presentation/blocs/image_detection/image_detection_bloc.dart';




  Future<void> pickImageCamera(BuildContext context) async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      context.read<ImageDetectionBloc>().add(ImagePicked(File(image.path)));
    }
  }

  Future<void> pickImageGallery(BuildContext context) async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      context.read<ImageDetectionBloc>().add(ImagePicked(File(image.path)));
    }
  }

