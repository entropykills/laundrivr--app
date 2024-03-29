import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:laundrivr/src/data/model/filter.dart';
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
  static final RegExp _qrCodeRegex = RegExp("<(.*?)>");

  MobileScannerController cameraController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  bool _flashEnabled = false;
  bool _cameraFlippedForward = false;

  bool _isInCooldown = false;

  bool _tryingToNavigateAway = false;

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

  Future<AlertButton> showDialog(String title, String message) async {
    return FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.information,
        windowPosition: AlertWindowPosition.screenCenter);
  }

  void _handleQrDetected(Barcode barcode) async {
    if (_tryingToNavigateAway) {
      return;
    }
    if (barcode.rawValue == null) {
      debugPrint('Failed to scan Barcode');
    } else {
      // match regex
      final matches = _qrCodeRegex.firstMatch(barcode.rawValue!);
      String? code = matches?.group(1);
      // if no match
      if (matches == null || code == null) {
        showDialog('Unknown QR Code',
            'We are not sure how to handle this QR code. Please try again.');
        return;
      }

      Filter<String> filter;
      log('Scanned code: $code');

      // if the qr code length is 3, the filter for finding the device is the ending digits
      if (code.length == 3) {
        filter = ClassicMachineFilter(code);
      } else if (code.length == 18) {
        String associatedValue = code.substring(12, 18);
        filter = OtherMachineFilter(associatedValue);
      } else if (code.length == 16) {
        String associatedValue = code.substring(10, 16);
        filter = OtherMachineFilter(associatedValue);
      } else {
        // show dialog saying we aren't sure how to handle this qr code
        showDialog('Unknown QR Code',
            'We are not sure how to handle this QR code. Please try again.');
        return;
      }

      // disable scanning so we don't keep getting the same code
      // even after navigating away (issue #1)
      await cameraController.stop();
      // set the navigation flag
      _tryingToNavigateAway = true;

      if (mounted) {
        // redirect to the starting screen and pass the code
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StartingScreen(
                  machineFilter: filter,
                )));
      } else {
        log('Tried to navigate to starting screen, but the widget was not mounted');
      }
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
        const Duration(seconds: 1),
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
                    child: BackButtonContainer(laundrivrTheme: laundrivrTheme),
                  ),
                  // flex
                  const Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: ToggleFlashContainer(
                        laundrivrTheme: laundrivrTheme,
                        flashEnabled: _flashEnabled),
                  ),
                  const SizedBox(width: 25),
                  GestureDetector(
                    onTap: _switchCamera,
                    child: SwitchCameraContainer(
                        laundrivrTheme: laundrivrTheme,
                        cameraFlippedForward: _cameraFlippedForward),
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

class SwitchCameraContainer extends StatelessWidget {
  const SwitchCameraContainer({
    Key? key,
    required this.laundrivrTheme,
    required bool cameraFlippedForward,
  })  : _cameraFlippedForward = cameraFlippedForward,
        super(key: key);

  final LaundrivrTheme laundrivrTheme;
  final bool _cameraFlippedForward;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: laundrivrTheme.opaqueBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(100))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            _cameraFlippedForward ? Icons.camera_front : Icons.camera_rear,
            size: 45,
            color: laundrivrTheme.primaryBrightTextColor,
          ),
        ));
  }
}

class ToggleFlashContainer extends StatelessWidget {
  const ToggleFlashContainer({
    Key? key,
    required this.laundrivrTheme,
    required bool flashEnabled,
  })  : _flashEnabled = flashEnabled,
        super(key: key);

  final LaundrivrTheme laundrivrTheme;
  final bool _flashEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: laundrivrTheme.opaqueBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(100))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            _flashEnabled ? Icons.flash_on : Icons.flash_off,
            size: 45,
            color: laundrivrTheme.primaryBrightTextColor,
          ),
        ));
  }
}

class BackButtonContainer extends StatelessWidget {
  const BackButtonContainer({
    Key? key,
    required this.laundrivrTheme,
  }) : super(key: key);

  final LaundrivrTheme laundrivrTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: laundrivrTheme.backButtonBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(100))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.arrow_back,
            size: 45,
            color: laundrivrTheme.primaryBrightTextColor,
          ),
        ));
  }
}
