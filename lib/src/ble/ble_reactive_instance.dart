import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleReactiveInstance {
  /// Create a singleton instance of flutter reactive ble
  BleReactiveInstance._privateConstructor();

  static final BleReactiveInstance _instance =
      BleReactiveInstance._privateConstructor();

  factory BleReactiveInstance() {
    return _instance;
  }

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  FlutterReactiveBle get ble => _ble;
}
