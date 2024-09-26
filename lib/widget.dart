import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'clipper.dart';
import 'credit_card.dart';

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

  final Color? colorOverlay;

  final ShapeBorder? shapeBorder;

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
  });

  @override
  State<CameraScannerWidget> createState() => _CameraScannerWidgetState();
}

class _CameraScannerWidgetState extends State<CameraScannerWidget>
    with WidgetsBindingObserver {
  /// The camera controller used to manage the device's camera.
  CameraController? controller;
  CameraController? controller2;

  /// Text recognizer used to process images and extract text.
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Notifier to manage the loading state of the camera.
  final valueLoading = ValueNotifier<bool>(true);

  /// Flag to prevent multiple simultaneous scans.
  bool scanning = false;

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
                                cutOutSize: 400,
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

    textRecognizer.close();
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

  /// Processes the recognized text to extract credit card information.
  ///
  /// This method analyzes the [RecognizedText] to identify the card number,
  /// cardholder's name, and expiration date.
  void onScanText(RecognizedText readText) {
    String cardNumber = '';
    String cardName = '';
    String cardExpirationMonth = '';
    String cardExpirationYear = '';

    // Process each text block to identify card information
    for (TextBlock block in readText.blocks) {
      // Check for expiration date
      if (block.text.contains(RegExp(r'\/')) &&
          block.text.length > 4 &&
          block.text.length < 10) {
        final text = block.text;

        if (text.contains('/')) {
          cardExpirationMonth = text.split('/').first;
          cardExpirationYear = text.split('/').last;

          if (cardExpirationMonth.length == 1) {
            cardExpirationMonth = '0$cardExpirationMonth';
          }

          if (cardExpirationYear.length == 2 &&
              cardExpirationYear.length == 2) {
            if (int.tryParse(cardExpirationYear) != null &&
                int.tryParse(cardExpirationYear) != null) {
              continue;
            }
          }
        }
      }

      // Check for card number
      if (block.text.contains(RegExp(r'[0-9]')) && block.text.length > 10) {
        final text = block.text;
        if (text.contains(' ') &&
            int.tryParse(text.replaceAll(" ", "")) != null &&
            text.split(" ").length == 4 &&
            text.split(" ").every((element) => element.length == 4)) {
          cardNumber = text;
          continue;
        }
      }

      // Check for cardholder's name
      if (block.text.contains(RegExp(r'[a-zA-Z]')) &&
          block.text.contains(' ')) {
        final hasNumber = block.text.contains(RegExp(r'[0-9]'));

        if (block.text.contains('\n') && hasNumber) {
          final lines = block.text.split('\n');

          if (lines.isNotEmpty &&
              lines.any((element) =>
                  element.contains(' ') &&
                  !element.contains(RegExp(r'[0-9]')))) {
            cardName = lines.firstWhere((element) =>
                element.contains(' ') && !element.contains(RegExp(r'[0-9]')));
            continue;
          }
        }
        if (hasNumber) {
          continue;
        }
        final hasEndOfLine = block.text.contains(RegExp(r'\n'));
        if (hasEndOfLine) {
          final lines = block.text.split('\n');

          if (lines.isNotEmpty &&
              lines.any((element) => element.contains(' '))) {
            cardName = lines.firstWhere((element) => element.contains(' '));
            continue;
          }
        }
        cardName = block.text;
      }
    }

    // Call onScan callback if required information is found
    if ((cardNumber.isNotEmpty || !widget.cardNumber) &&
        (cardName.isNotEmpty || !widget.cardHolder) &&
        ((cardExpirationYear.isNotEmpty && cardExpirationMonth.isNotEmpty) ||
            !widget.cardExpiryDate)) {
      widget.onScan(
        context,
        CreditCardModel(
          number: cardNumber,
          expirationMonth: cardExpirationMonth,
          expirationYear: cardExpirationYear,
          holderName: cardName,
        ),
      );
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
    try {
      final textR = await textRecognizer.processImage(inputImage);

      if (textR.text.isNotEmpty) {
        onScanText(textR);
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        scanning = false;
      });
    } catch (e) {
      scanning = false;
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
      imageFormatGroup:
          Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.yuv420,
    );

    controller = cameraController;

    await cameraController.initialize();

    valueLoading.value = false;

    await cameraController.startImageStream((CameraImage image) async {
      process(image, description);
    });
  }
}
