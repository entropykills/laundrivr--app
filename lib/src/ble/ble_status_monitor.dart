import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:laundrivr/src/ble/reactive_state.dart';

import 'ble_reactive_instance.dart';

class BleStatusMonitor implements ReactiveState<BleStatus?> {
  /// Make a singleton instance of the BleStatusMonitor
  BleStatusMonitor._privateConstructor();

  static final BleStatusMonitor _instance =
      BleStatusMonitor._privateConstructor();

  factory BleStatusMonitor() {
    return _instance;
  }

  final FlutterReactiveBle _ble = BleReactiveInstance().ble;

  @override
  Stream<BleStatus?> get state => _ble.statusStream;
}
