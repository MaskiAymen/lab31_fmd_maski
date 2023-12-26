import 'dart:io';

class ImageDetectionState {
  final bool loading;
  final File? image;
  final List? output;

  ImageDetectionState({required this.loading, this.image, this.output});

  ImageDetectionState copyWith({bool? loading, File? image, List? output}) {
    return ImageDetectionState(
      loading: loading ?? this.loading,
      image: image ?? this.image,
      output: output ?? this.output,
    );
  }
}
