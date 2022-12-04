import 'dart:math';

import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_svg/svg.dart';

import '../../data/adapter/ble_communicator_adapter_reactive.dart';
import '../../data/filter.dart';
import '../../data/utils/result/data_machine_result.dart';
import '../theme/laundrivr_theme.dart';

class StartingScreen extends StatefulWidget {
  const StartingScreen({Key? key, required this.targetMachineNameEnding})
      : super(key: key);

  final String targetMachineNameEnding;

  @override
  State<StartingScreen> createState() => _StartingScreenState();
}

class _StartingScreenState extends State<StartingScreen> {
  // list of different loading messages
  static const List<String> loadingMessages = [
    "Connecting you to a freshly washed future!",
    "Spinning your way to a spotless wardrobe!",
    "Folding your way to a brighter tomorrow!",
    "Getting your clothes squeaky clean!",
    "Making sure your whites stay white and your colors stay bright!",
    "Making sure your Monday morning outfit is ready to go!",
    "Connecting you to a wrinkle-free future!",
    "Making sure you always look your best!",
    "Letting the machines do the hard work for you!",
  ];

  // pick a random loading message (dart)
  final String _loadingMessage =
      loadingMessages[Random().nextInt(loadingMessages.length)];

  Future<AlertButton> showDialog(String title, String message) async {
    return FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.information,
        windowPosition: AlertWindowPosition.screenCenter);
  }

  void _executeBleTransaction(String targetMachineNameEnding) async {
    // create new ble communicator adapter
    final BleCommunicatorAdapter4 bleCommunicatorAdapter =
        BleCommunicatorAdapter4();

    // start the ble transaction
    var result = await bleCommunicatorAdapter
        .execute(EndsWithFilter(targetMachineNameEnding));

    String title = "";
    String message = "";

    if (result.anErrorOccurred) {
      if (result.associatedErrorMessage != null) {
        title = "Something went wrong.";
        message = result.associatedErrorMessage!;
      } else {
        title = "Something went wrong.";
        message = "This machine is not available.";
      }
    } else {
      // get data machine result
      DataMachineResult dataMachineResult = result.dataMachineResult!;
      if (dataMachineResult.didCompleteSuccessfulTransaction) {
        title = "Started your laundry!";
        message = "Your laundry load has been started.";
      } else {
        title = "Something went wrong.";
        message = "The start button was not pressed.";
      }
    }

    showDialog(title, message).whenComplete(() => Navigator.of(context).pop());
  }

  @override
  void initState() {
    super.initState();
    _executeBleTransaction(
        widget.targetMachineNameEnding // execute the ble transaction
        );
  }

  @override
  Widget build(BuildContext context) {
    final String targetMachineDigits = widget.targetMachineNameEnding;
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return Scaffold(
        backgroundColor: laundrivrTheme.opaqueBackgroundColor,
        body: Stack(
          children: [
            SafeArea(
                child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Center(
                  child: SizedBox(
                width: 300,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                          "assets/images/laundrivr_logo+text_golden.svg",
                          semanticsLabel: 'Laundrivr Logo',
                          width: 100,
                          height: 100),
                      const SizedBox(height: 100),
                      Text(
                        _loadingMessage,
                        textAlign: TextAlign.center,
                        style: laundrivrTheme.primaryTextStyle!.copyWith(
                            fontSize: 35, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 25),
                      // loading gif
                      Image.asset(
                        "assets/images/washing-machine-loading.gif",
                        color: laundrivrTheme.primaryBrightTextColor,
                        width: 100,
                        height: 100,
                      ),
                    ]),
              )),
            )),
            Positioned.fill(
                child: FloatingBubbles.alwaysRepeating(
              noOfBubbles: 10,
              colorsOfBubbles: const [Colors.blue],
              sizeFactor: 0.2,
              opacity: 80,
              paintingStyle: PaintingStyle.fill,
              strokeWidth: 12,
              shape: BubbleShape.circle,
              // circle is the default. No need to explicitly mention if its a circle.
              speed: BubbleSpeed.fast, // normal is the default
            )),
          ],
        ));
  }
}
