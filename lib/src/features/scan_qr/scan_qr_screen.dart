import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../qr/QrScannerOverlayShape.dart';
import '../starting/starting_screen.dart';
import '../theme/laundrivr_theme.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  MobileScannerController cameraController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  bool _flashEnabled = false;
  bool _cameraFlippedForward = false;

  bool _isInCooldown = false;

  Future<void> _backToHome() async {
    // push back to home
    Navigator.of(context).pop();
  }

  void _toggleFlash() {
    cameraController.toggleTorch();

    setState(() {
      _flashEnabled = !_flashEnabled;
    });
  }

  void _switchCamera() {
    cameraController.switchCamera();

    setState(() {
      _cameraFlippedForward = !_cameraFlippedForward;
    });
  }

  void _handleQrDetected(Barcode barcode) {
    if (barcode.rawValue == null) {
      debugPrint('Failed to scan Barcode');
    } else {
      final String code = barcode.rawValue!;

      // strip all non-numeric characters
      final String targetMachineNameEnding = code.replaceAll(RegExp(r'\D'), '');

      // redirect to the starting screen and pass the code
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StartingScreen(
                targetMachineNameEnding: targetMachineNameEnding,
              )));
    }
  }

  void _onDetect(
    Barcode barcode,
  ) {
    if (_isInCooldown) return;
    setState(() {
      _isInCooldown = true;
    });
    Timer(
        const Duration(seconds: 3),
        () => setState(
            () => _isInCooldown = false)); // cooldown to prevent multiple scans

    _handleQrDetected(barcode);
  }

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return Scaffold(
        body: Stack(
      children: [
        MobileScanner(
            allowDuplicates: true,
            controller: cameraController,
            onDetect: (barcode, args) => _onDetect(barcode)),
        Padding(
          padding: EdgeInsets.zero, //widget.overlayMargin,
          child: Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                  borderRadius: 40,
                  borderColor: laundrivrTheme.primaryBrightTextColor!,
                  borderLength: 30,
                  borderWidth: 10),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 25),
                  GestureDetector(
                    onTap: _backToHome,
                    child: Container(
                        decoration: BoxDecoration(
                            color: laundrivrTheme.backButtonBackgroundColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back,
                            size: 45,
                            color: laundrivrTheme.primaryBrightTextColor,
                          ),
                        )),
                  ),
                  // flex
                  const Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: Container(
                        decoration: BoxDecoration(
                            color: laundrivrTheme.opaqueBackgroundColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            _flashEnabled ? Icons.flash_on : Icons.flash_off,
                            size: 45,
                            color: laundrivrTheme.primaryBrightTextColor,
                          ),
                        )),
                  ),
                  const SizedBox(width: 25),
                  GestureDetector(
                    onTap: _switchCamera,
                    child: Container(
                        decoration: BoxDecoration(
                            color: laundrivrTheme.opaqueBackgroundColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            _cameraFlippedForward
                                ? Icons.camera_front
                                : Icons.camera_rear,
                            size: 45,
                            color: laundrivrTheme.primaryBrightTextColor,
                          ),
                        )),
                  ),
                  const SizedBox(width: 25),
                ],
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
