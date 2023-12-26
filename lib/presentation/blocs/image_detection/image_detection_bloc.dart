import 'package:lab31_fmd_maski/presentation/blocs/image_detection/image_detection_state.dart';

import 'image_detection_event.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tflite/tflite.dart';


class ImageDetectionBloc extends Bloc<ImageDetectionEvent, ImageDetectionState> {
  ImageDetectionBloc() : super(ImageDetectionState(loading: true));

  @override
  Stream<ImageDetectionState> mapEventToState(ImageDetectionEvent event) async* {
    if (event is ImagePicked) {
      yield* _mapImagePickedToState(event.image);
    }
  }

  Stream<ImageDetectionState> _mapImagePickedToState(File image) async* {
    yield state.copyWith(loading: true);

    try {
      var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      yield state.copyWith(loading: false, image: image, output: prediction);
    } catch (e) {
      print('Error during image prediction: $e');
      yield state.copyWith(loading: false);
    }
  }



}
class ImagePicked extends ImageDetectionEvent {
  final File image;

  ImagePicked(this.image);
}

class DetectionStarted extends ImageDetectionEvent {}
