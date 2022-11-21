import 'dart:async';
import 'dart:developer';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'ble_reactive_instance.dart';

class BleDeviceInteractor {
  BleDeviceInteractor()
      : _bleDiscoverServices = BleReactiveInstance().ble.discoverServices,
        _readCharacteristic = BleReactiveInstance().ble.readCharacteristic,
        _writeWithResponse =
            BleReactiveInstance().ble.writeCharacteristicWithResponse,
        _writeWithoutResponse =
            BleReactiveInstance().ble.writeCharacteristicWithoutResponse,
        _subscribeToCharacteristic =
            BleReactiveInstance().ble.subscribeToCharacteristic,
        _logMessage = log;

  final Future<List<DiscoveredService>> Function(String deviceId)
      _bleDiscoverServices;

  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      _readCharacteristic;

  final Future<void> Function(QualifiedCharacteristic characteristic,
      {required List<int> value}) _writeWithResponse;

  final Future<void> Function(QualifiedCharacteristic characteristic,
      {required List<int> value}) _writeWithoutResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      _subscribeToCharacteristic;

  final void Function(String message) _logMessage;

  Future<List<DiscoveredService>> discoverServices(String deviceId) async {
    try {
      _logMessage('Start discovering services for: $deviceId');
      final result = await _bleDiscoverServices(deviceId);
      _logMessage('Discovering services finished');
      return result;
    } on Exception catch (e) {
      _logMessage('Error occurred when discovering services: $e');
      rethrow;
    }
  }

  Future<List<int>> readCharacteristic(
      QualifiedCharacteristic characteristic) async {
    try {
      final result = await _readCharacteristic(characteristic);

      _logMessage('Read ${characteristic.characteristicId}: value = $result');
      return result;
    } on Exception catch (e, s) {
      _logMessage(
        'Error occurred when reading ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacteristicWithResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      _logMessage(
          'Write with response value : $value to ${characteristic.characteristicId}');
      await _writeWithResponse(characteristic, value: value);
    } on Exception catch (e, s) {
      _logMessage(
        'Error occurred when writing ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacteristicWithoutResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      await _writeWithoutResponse(characteristic, value: value);
      _logMessage(
          'Write without response value: $value to ${characteristic.characteristicId}');
    } on Exception catch (e, s) {
      _logMessage(
        'Error occured when writing ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Stream<List<int>> subScribeToCharacteristic(
      QualifiedCharacteristic characteristic) {
    _logMessage('Subscribing to: ${characteristic.characteristicId} ');
    return _subscribeToCharacteristic(characteristic).asBroadcastStream();
  }
}
