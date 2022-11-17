import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:laundrivr/src/data/filter.dart';
import 'package:laundrivr/src/data/machine/ble_data_machine.dart';
import 'package:laundrivr/src/data/utils/ble_constants.dart';
import 'package:laundrivr/src/data/utils/cscsw_constants.dart';

import './adapter.dart';

/// A class that contains the logic for adapting BLE
class BleAdapter implements Adapter<FlutterBluePlus> {
  /// A filter to filter out device names of type 1
  static final Filter<String> _typeTwoMachineNameFilter =
      ContainsFilter(CscswConstants.typeTwoBLENameBeginning);

  /// The instance of the FlutterBluePlus class
  final FlutterBluePlus flutterBluePlus = FlutterBluePlus.instance;

  /// If FlutterBluePlus is currently scanning
  bool _scanning = false;

  /// define target guids
  late Guid _targetServiceGuid;
  late Guid _targetCharWriteGuid;
  late Guid _targetCharNotifyGuid;

  /// define target characteristics and service for communication
  late BluetoothCharacteristic _targetCharWrite;
  late BluetoothCharacteristic _targetCharNotify;
  late BluetoothService _targetService;

  /// The Bluetooth data machine
  late BleDataMachine _dataMachine;

  /// A function to update a loading spinner on the home page
  /// todo temporary
  late void Function(bool) _updateShowLoadingSpinner;

  /// A function that when called, shows a dialog
  /// todo temporary
  late void Function(String, String) _showMyDialog;

  // add a constructor
  BleAdapter(
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
    // initialize the found device flag

    // update the loading spinner
    _updateShowLoadingSpinner(true);

    // scan for 5 seconds
    await flutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // listen for results and call a callback with the results
    flutterBluePlus.scanResults.listen((results) async {
      // if the results do not contain the target device
      if (!results
          .any((element) => targetMachineDigitsFilter(element.device.name))) {
        // do nothing, since the device hasn't been found yet
        return;
      }

      // the device was found, so stop scanning
      await _stopScanning();

      // update the found device flag

      // get the target device
      var result = results.firstWhere(
          (element) => targetMachineDigitsFilter(element.device.name));

      // connect to the device
      await _connectToDevice(result.device);

      // call the on connection 'callback'
      await _onConnection(result.device);
    });

    // wait for 5 seconds
    await Future.delayed(const Duration(seconds: 5));

    // if already not scanning, we found the device- so we can just return
    if (!_scanning) {
      return;
    }

    await _stopScanning();

    // we definitely didn't find the device so let's send some messages
    log("Device not found!");

    // add a popup
    _showMyDialog("Error", "The target device wasn't found.");
  }

  Future<void> _stopScanning() async {
    // stop scanning
    await flutterBluePlus.stopScan();
    // set the scanning flag to false
    _scanning = false;
    // update the loading spinner to disappear
    _updateShowLoadingSpinner(false);
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

    _showMyDialog("Success", "Remote machine connection success.");

    // start the data machine
    _dataMachine.start();
  }

  // add a method to write data
  Future<void> writeData(List<List<int>> data) async {
    // loop through each packet and write it
    for (List<int> packet in data) {
      // wait for the write request to go through so all data is sent!
      await _targetCharWrite.write(packet, withoutResponse: false);
    }
  }

  @override
  FlutterBluePlus provideAdaption() {
    return flutterBluePlus;
  }
}
