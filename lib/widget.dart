import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:apple_vision_recognize_text/apple_vision_recognize_text.dart'
    as apple;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'clipper.dart';
import 'credit_card.dart';
import 'helpers.dart';
import 'process.dart';

/// A widget that displays a live camera preview and scans for credit card information.
///
/// This widget uses the device's camera to capture images and performs optical character
/// recognition (OCR) to extract text from the images. It then analyzes the extracted
/// text to identify credit card numbers, cardholder names, and expiry dates.
///
/// The widget provides callbacks for successful scans and errors, allowing developers
/// to handle scanned credit card data and display appropriate UI feedback.
///
/// To use the widget, simply create an instance of [CameraScannerWidget] and provide
/// the required callbacks:
///
/// ```dart
/// CameraScannerWidget(
///   onScan: (context, creditCardModel) {
///     // Handle the scanned credit card data here
///   },
///   loadingHolder: Center(child: CircularProgressIndicator()),
///   onNoCamera: () {
///     // Handle the case where no camera is available
///   },
/// )
/// ```
///
/// The [onScan] callback is triggered when a credit card is successfully scanned,
/// providing a [CreditCardModel] object containing the extracted card information.
///
/// The [loadingHolder] widget is displayed while the camera is initializing.
///
/// The [onNoCamera] callback is triggered if no camera is available on the device.
class CameraScannerWidget extends StatefulWidget {
  /// Callback function called when a credit card is successfully scanned.
  final void Function(BuildContext, CreditCardModel?) onScan;

  /// Widget to display while the camera is initializing.
  final Widget loadingHolder;

  /// Callback function called when no camera is available on the device.
  final void Function() onNoCamera;

  /// Aspect ratio for the camera preview. If null, uses the device's screen aspect ratio.
  final double? aspectRatio;

  /// Whether to scan for the card number. Defaults to true.
  final bool cardNumber;

  /// Whether to scan for the card holder's name. Defaults to true.
  final bool cardHolder;

  /// Whether to scan for the card's expiry date. Defaults to true.
  final bool cardExpiryDate;

  /// The color of the overlay that highlights the credit card scanning area.
  final Color? colorOverlay;

  /// The shape of the border surrounding the credit card scanning area.
  final ShapeBorder? shapeBorder;

  /// this will force validation of the card number means it will apply luhn algorithm to the card number
  final bool useLuhnValidation;

  /// Creates a [CameraScannerWidget].
  ///
  /// The [onScan], [loadingHolder], and [onNoCamera] parameters are required.
  const CameraScannerWidget({
    super.key,
    required this.onScan,
    required this.loadingHolder,
    required this.onNoCamera,
    this.aspectRatio,
    this.cardNumber = true,
    this.cardHolder = true,
    this.cardExpiryDate = true,
    this.colorOverlay,
    this.shapeBorder,
    this.useLuhnValidation = true,
  });

  @override
  State<CameraScannerWidget> createState() => _CameraScannerWidgetState();
}

class _CameraScannerWidgetState extends State<CameraScannerWidget>
    with WidgetsBindingObserver {
  final appleVisionController = apple.AppleVisionRecognizeTextController();

  /// The camera controller used to manage the device's camera.
  CameraController? controller;

  /// Text recognizer used to process images and extract text.
  final mlTextRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Notifier to manage the loading state of the camera.
  final valueLoading = ValueNotifier<bool>(true);

  /// Flag to prevent multiple simultaneous scans.
  bool scanning = false;

  late final _process = ProccessCreditCard(
      useLuhnValidation: widget.useLuhnValidation,
      checkCreditCardNumber: widget.cardNumber,
      checkCreditCardName: widget.cardHolder,
      checkCreditCardExpiryDate: widget.cardExpiryDate);
  Color get colorOverlay =>
      widget.colorOverlay ?? Colors.black.withOpacity(0.8);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ValueListenableBuilder(
      valueListenable: valueLoading,
      builder: (context, isLoading, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? widget.loadingHolder
              : Stack(
                  children: [
                    // Camera
                    // AspectRatio(
                    //     aspectRatio: MediaQuery.of(context).size.aspectRatio,
                    //     child: CameraPreview(controller!)),

                    // Overlay
                    Container(
                      width: size.width,
                      height: size.height,
                      color: Colors.black,
                    ),
                    Center(child: CameraPreview(controller!)),

                    Container(
                      decoration: ShapeDecoration(
                        shape: widget.shapeBorder ??
                            OverlayShape(
                                cutOutHeight: size.height * 0.3,
                                cutOutWidth: size.width * 0.95,
                                overlayColor: colorOverlay,
                                borderRadius: 20),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    if (controller != null) {
      controller!.dispose();
    }

    mlTextRecognizer.close();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    availableCameras().then((v) async {
      if (v.isEmpty) {
        if (mounted) {
          widget.onNoCamera();
        }
        return;
      }

      final c = v.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back);

      _initializeCameraController(c);
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        log(error.toString());
        log(stackTrace.toString());
      }
      if (mounted) {
        widget.onNoCamera();
      }
    });
  }

  void onScanApple(List<apple.RecognizedText> list) {
    CreditCardModel? creditCardModel;

    for (var item in list) {
      for (var element in item.listText) {
        _process.processNumber(element);
        _process.processName(element);
        _process.processDate(element);
      }
    }
    creditCardModel = _process.getCreditCardModel();

    if (creditCardModel != null) {
      widget.onScan(context, creditCardModel);
    }
  }

  /// Processes the recognized text to extract credit card information.
  ///
  /// This method analyzes the [RecognizedText] to identify the card number,
  /// cardholder's name, and expiration date.
  void onScanTextML(RecognizedText readText) {
    // Call onScan callback if required information is found
    CreditCardModel? creditCardModel;
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        _process.processNumber(line.text);

        _process.processName(line.text);
        _process.processDate(line.text);
        // for (TextElement element in line.elements) {
        //   final text = element.text;

        // }
      }

      creditCardModel = _process.getCreditCardModel();
    }

    if (creditCardModel != null) {
      widget.onScan(context, creditCardModel);
    }
  }

  void process(CameraImage image, CameraDescription description) async {
    if (scanning) return;

    scanning = true;

    final InputImageRotation imageRotation =
        InputImageRotationValue.fromRawValue(description.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final List<int> bytes =
        image.planes.expand((plane) => plane.bytes).toList();

    try {
      if (Platform.isIOS) {
        final textR = await appleVisionController.processImage(
            apple.RecognizeTextData(
                automaticallyDetectsLanguage: false,
                languages: [const Locale('en', 'US')],
                recognitionLevel: apple.RecognitionLevel.accurate,
                image: Uint8List.fromList(bytes),
                orientation: imageRotation.appleRotation,
                imageSize:
                    Size(image.width.toDouble(), image.height.toDouble())));

        if (textR?.isNotEmpty == true) {
          onScanApple(textR!);
        }
      } else {
        final InputImage inputImage = InputImage.fromBytes(
          bytes: Uint8List.fromList(bytes),
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: imageRotation,
            format: Platform.isAndroid
                ? InputImageFormat.nv21
                : InputImageFormat.yuv420,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
        final textR = await mlTextRecognizer.processImage(inputImage);

        if (textR.text.isNotEmpty) {
          onScanTextML(textR);
        }
      }

      Future.delayed(const Duration(milliseconds: 1000), () {
        scanning = false;
      });
    } catch (e) {
      // scanning = false;
    }
  }

  /// Initializes the camera controller and starts the image stream.
  ///
  /// This method sets up the camera with the given [description],
  /// initializes the controller, and begins processing images for text recognition.
  Future<void> _initializeCameraController(
      CameraDescription description) async {
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    controller = cameraController;

    await cameraController.initialize();

    valueLoading.value = false;

    await cameraController.startImageStream((CameraImage image) async {
      process(image, description);
    });
  }
}
