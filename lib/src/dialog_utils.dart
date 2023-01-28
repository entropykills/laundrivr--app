import 'package:flutter_platform_alert/flutter_platform_alert.dart';

class DialogUtils {
  static final DialogUtils _instance = DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;

  Future<AlertButton> showDialog(String title, String message) async {
    return FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.information,
        windowPosition: AlertWindowPosition.screenCenter);
  }

  Future<void> showDialogWithActions(
      String title, String message, Map<AlertButton, Function> actions) async {
    AlertButton response = await FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.information,
        windowPosition: AlertWindowPosition.screenCenter);
    for (var action in actions.entries) {
      if (action.key == response) {
        action.value();
      }
    }
  }
}
