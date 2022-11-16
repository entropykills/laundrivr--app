import 'dart:developer' as developer;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:laundrivr/src/data/filter.dart';

class BleFunctionalTest {
  FlutterBluePlus flutterBluePlus = FlutterBluePlus.instance;
  bool _scanning = false;
  int _numResults = 0;

  final ContainsFilter _deviceNameFilter = ContainsFilter('SoundLink');

  // add callback param
  Future<int> start() async {
    if (_scanning) {
      return 0;
    }
    _scanning = true;

    developer.log("STARTING BLE TEST");

    // start scanning
    flutterBluePlus
        .scan(
      timeout: const Duration(seconds: 4),
    )
        .listen((event) {
      developer.log('${event.device.name} found! rssi: ${event.rssi}');
      if (_deviceNameFilter(event.device.name)) {
        _numResults++;
      }
    });

    await Future.delayed(const Duration(seconds: 5));

    // Stop scanning
    flutterBluePlus.stopScan();
    _scanning = false;

    return _numResults;
  }
}
