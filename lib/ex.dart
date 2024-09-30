import 'package:apple_vision_commons/src/enums/camera_facing.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

extension InputImageRotationExt on InputImageRotation {
  ImageOrientation get appleRotation {
    switch (this) {
      case InputImageRotation.rotation0deg:
        return ImageOrientation.up;
      case InputImageRotation.rotation90deg:
        return ImageOrientation.right;
      case InputImageRotation.rotation180deg:
        return ImageOrientation.left;
      case InputImageRotation.rotation270deg:
        return ImageOrientation.down;

      default:
        return ImageOrientation.up;
    }
  }
}
