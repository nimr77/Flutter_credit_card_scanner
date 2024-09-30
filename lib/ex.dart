import 'package:apple_vision_commons/src/enums/camera_facing.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

extension InputImageRotationExt on InputImageRotation {
  ImageOrientation get appleRotation {
    switch (this) {
      case InputImageRotation.rotation0deg:
        return ImageOrientation.up;
      case InputImageRotation.rotation90deg:
        return ImageOrientation.upMirrored;
      case InputImageRotation.rotation180deg:
        return ImageOrientation.down;
      case InputImageRotation.rotation270deg:
        return ImageOrientation.downMirrored;

      default:
        return ImageOrientation.up;
    }
  }
}
