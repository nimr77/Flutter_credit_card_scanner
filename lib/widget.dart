import 'package:camera/camera.dart';
import 'package:credit_card_scanner/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraScannerWidgetCamera extends StatefulWidget {
  final void Function(BuildContext, CreditCardModel?) onScan;

  final Widget loadingHolder;

  final void Function() onNoCamera;

  final double? aspectRatio;
  const CameraScannerWidgetCamera(
      {super.key,
      required this.onScan,
      required this.loadingHolder,
      required this.onNoCamera,
      this.aspectRatio});

  @override
  State<CameraScannerWidgetCamera> createState() =>
      _CameraScannerWidgetCameraState();
}

class _CameraScannerWidgetCameraState extends State<CameraScannerWidgetCamera>
    with WidgetsBindingObserver {
  static CameraController? controller;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final valueLoading = ValueNotifier<bool>(true);

  bool scanning = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: valueLoading,
          builder: (context, isLoading, _) {
            return Stack(
              children: [
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? widget.loadingHolder
                        : AspectRatio(
                            aspectRatio: widget.aspectRatio ??
                                MediaQuery.of(context).size.aspectRatio,
                            child: CameraPreview(controller!))),

                // close button
                // Align(
                //     alignment: Alignment.topLeft,
                //     child: SafeArea(
                //       child: IconButton(
                //           icon: const Icon(
                //             Icons.close,
                //           ),
                //           onPressed: () {
                //             if (controller != null) {
                //               controller!.dispose();
                //             }
                //             context.pop();
                //           }),
                //     ))
              ],
            );
          }),
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
          // await showOkAlertDialog(context: context, message: S.current.error);
          // if (mounted) context.pop();

          widget.onNoCamera();
        }
        return;
      }

      final c = v.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back);

      _initializeCameraController(c);
    });
  }

  onScanText(RecognizedText readText) {
    String cardNumber = '';
    String cardName = '';
    String cardExpirationMonth = '';
    String cardExpirationYear = '';

    // check the blocks to see if they are a number, name, or expiration and which block is which (if any)
    for (TextBlock block in readText.blocks) {
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
            // both should be numbers
            if (int.tryParse(cardExpirationYear) != null &&
                int.tryParse(cardExpirationYear) != null) {
              continue;
            }
          }
        }
      }

      if (block.text.contains(RegExp(r'[0-9]')) && block.text.length > 10) {
        final text = block.text;
        // if only numbers, then it's a card number and its ok to have spaces
        if (text.contains(' ') &&
            int.tryParse(text.replaceAll(" ", "")) != null &&
            text.split(" ").length == 4 &&
            text.split(" ").every((element) => element.length == 4)) {
          cardNumber = text;
          continue;
        }
      }
      if (block.text.contains(RegExp(r'[a-zA-Z]')) &&
          block.text.contains(' ')) {
        cardName = block.text;

        continue;
      }
    }

    if (cardNumber.isNotEmpty &&
        cardName.isNotEmpty &&
        cardExpirationYear.isNotEmpty &&
        cardExpirationMonth.isNotEmpty) {
      widget.onScan(
          context,
          CreditCardModel(
              number: cardNumber,
              expirationMonth: cardExpirationMonth,
              expirationYear: cardExpirationYear,
              // cvv: "",
              holderName: cardName));
    }
  }

  _initializeCameraController(CameraDescription description) async {
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    controller = cameraController;

    await cameraController.initialize();

    valueLoading.value = false;
    await cameraController.startImageStream((CameraImage image) async {
      if (scanning) return;
      scanning = true;
      if (image.format.group != ImageFormatGroup.yuv420) {
        return;
      }

      final InputImageRotation imageRotation =
          InputImageRotationValue.fromRawValue(description.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final InputImage inputImage = InputImage.fromBytes(
        bytes: Uint8List.fromList(
          image.planes.fold(
              <int>[],
              (List<int> previousValue, element) =>
                  previousValue..addAll(element.bytes)),
        ),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: imageRotation,
          format: InputImageFormat.yuv420,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final textR = await textRecognizer.processImage(inputImage);

      if (textR.text.isNotEmpty) {
        onScanText(textR);
      }

      scanning = false;
    });
  }
}
