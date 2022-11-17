import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:laundrivr/src/data/ble_constants.dart';
import 'package:laundrivr/src/data/ble_data_machine.dart';
import 'package:laundrivr/src/data/filter.dart';

/// A class that contains the logic for testing the BLE functionality.
class BleFunctionalTest {
  /// A filter to filter out device names of type 1
  static final Filter<String> _typeTwoMachineNameFilter =
      ContainsFilter("20COL");

  /// The instance of the FlutterBluePlus class
  final FlutterBluePlus flutterBluePlus = FlutterBluePlus.instance;

  /// If FlutterBluePlus is currently scanning
  bool _scanning = false;
  bool _foundDevice = false;

  /// define target guids
  late Guid _targetServiceGuid;
  late Guid _targetCharWriteGuid;
  late Guid _targetCharNotifyGuid;

  /// define target objects for communication
  late BluetoothCharacteristic _targetCharWrite;
  late BluetoothCharacteristic _targetCharNotify;
  late BluetoothService _targetService;

  /// initialize data machine
  late BleDataMachine _dataMachine;

  /// initialize the callback for showing the loading spinner on the home page
  late void Function(bool) _updateShowLoadingSpinner;

  late void Function(String, String) _showMyDialog;

  // add a constructor
  BleFunctionalTest(
    void Function(bool) updateShowLoadingSpinner,
    void Function(String, String) showMyDialog,
  ) {
    _dataMachine = BleDataMachine(this);
    _updateShowLoadingSpinner = updateShowLoadingSpinner;
    _showMyDialog = showMyDialog;
  }

  /// Starts the BLE device scanning and functional test
  Future<void> start(Filter<String> targetMachineDigitsFilter) async {
    // if scanning already, don't do anything
    if (_scanning) {
      return;
    }
    // set scanning to true so we don't start scanning twice
    _scanning = true;

    // update the loading spinner
    _updateShowLoadingSpinner(true);

    // start scanning for devices
    flutterBluePlus
        .scan(
      timeout: const Duration(seconds: 7),
    )
        .listen((event) async {
      log('${event.device.name} found! rssi: ${event.rssi}');
      // if the device name does not match the target digits
      if (!targetMachineDigitsFilter(event.device.name)) {
        return;
      }

      // stop scanning
      await flutterBluePlus.stopScan();
      // set scanning to false
      _scanning = false;

      // set found device to true
      _foundDevice = true;

      // connect to the device
      await _connectToDevice(event.device);

      // call the on connection 'callback'
      _onConnection(event.device);

      // update the loading spinner
      _updateShowLoadingSpinner(false);
    });

    // wait for 4 seconds
    await Future.delayed(const Duration(seconds: 7));

    // Stop scanning
    flutterBluePlus.stopScan();
    _scanning = false;

    // update the loading spinner
    _updateShowLoadingSpinner(false);

    // if we didn't find the device, send a message
    // log found device
    if (!_foundDevice) {
      log("Device not found!");

      // add a popup
      _showMyDialog("Error", "Device not found!");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // connect to the device
    await device.connect();
    log("Connected to device: ${device.name}");
  }

  Future<void> _onConnection(BluetoothDevice device) async {
    if (_typeTwoMachineNameFilter(device.name)) {
      // set the target characteristics & services
      _targetServiceGuid = BleConstants.type2ServiceGuid;
      _targetCharWriteGuid = BleConstants.type2CharWriteGuid;
      _targetCharNotifyGuid = BleConstants.type2CharNotifyGuid;
    } else {
      // set the target characteristics & services
      _targetServiceGuid = BleConstants.me51CharServiceGuid;
      _targetCharWriteGuid = BleConstants.me51CharWriteGuid;
      _targetCharNotifyGuid = BleConstants.me51CharNotifyGuid;
    }

    // discover all services
    List<BluetoothService> services = await device.discoverServices();

    // if the target isn't in the services, return
    if (!services.any((service) => service.uuid == _targetServiceGuid)) {
      // error message
      log("Target service not found!");
      return;
    }

    // get the target service
    _targetService =
        services.firstWhere((service) => service.uuid == _targetServiceGuid);

    // loop all services and see if the target characteristics are in the service, if not, return
    if (!_targetService.characteristics.any(
            (characteristic) => characteristic.uuid == _targetCharWriteGuid) ||
        !_targetService.characteristics.any(
            (characteristic) => characteristic.uuid == _targetCharNotifyGuid)) {
      // error message
      log("A target characteristic was not found!");
      return;
    }

    // log that we found the target service
    log("Target service found!");

    // get the target characteristics
    _targetCharWrite = _targetService.characteristics.firstWhere(
        (characteristic) => characteristic.uuid == _targetCharWriteGuid);
    _targetCharNotify = _targetService.characteristics.firstWhere(
        (characteristic) => characteristic.uuid == _targetCharNotifyGuid);

    // log that we found the target characteristics
    log("Target characteristics found!");

    // set the target characteristics to notify
    await _targetCharNotify.setNotifyValue(true);
    // create a callback for when the target characteristic is updated
    _targetCharNotify.value.listen((value) {
      // handle the value in the data-machine callback
      _dataMachine.onDataReceived(value);
    });

    _showMyDialog("Success", "Connection success.");

    // start the data machine
    _dataMachine.start();
  }

  // add a method to write data
  Future<void> writeData(List<List<int>> data) async {
    // loop through each packet and write it
    for (List<int> packet in data) {
      _targetCharWrite.write(packet, withoutResponse: false);
    }
  }
}
