import 'package:apple_vision_commons/src/enums/camera_facing.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Recognizes acceptable expiration date formats
/// In plain english the steps are:
///  1) The month:
///  a '0' followed by a number between '1' & '9 ' or just a number between '1' and '9'
///  <br>OR</br>
///  a '1' followed by a number between '0' & '2'
///  2) The slash:
///    a '/' (forward slash)
///  3) The year:
///    any combo of 2-4 numeric characters
final RegExp expDateFormat = RegExp(r'^((0?([1-9]))|1([0-2]))\/(\d{2,4})$');

/// Recognizes all whitespace characters
final RegExp whiteSpaceRegex = RegExp(r'-|\s+\b|\b\s');

/// Parses the string form of the expiration date and returns the month and year
/// as a `List<String>`
///
/// Allows for the following date formats:
///     'MM/YY'
///     'MM/YYY'
///     'MM/YYYY'
///
/// This function will replace hyphens with slashes for dates that have hyphens in them
/// and remove any whitespace
List<String> parseDate(String expDateStr) {
  // Replace hyphens with slashes and remove whitespaces
  String formattedStr = expDateStr.replaceAll('-', '/')
    ..replaceAll(whiteSpaceRegex, '');

  Match? match = expDateFormat.firstMatch(formattedStr);

  if (match == null) {
    return [];
  }

  return match[0]!.split('/');
}

extension InputImageRotationExt on InputImageRotation {
  ImageOrientation get appleRotation {
    switch (this) {
      case InputImageRotation.rotation0deg:
        return ImageOrientation.up;
      case InputImageRotation.rotation90deg:
        return ImageOrientation.up;
      case InputImageRotation.rotation180deg:
        return ImageOrientation.down;
      case InputImageRotation.rotation270deg:
        return ImageOrientation.downMirrored;
    }
  }
}
