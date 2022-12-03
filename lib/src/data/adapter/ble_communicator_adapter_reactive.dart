import 'dart:async';
import 'dart:developer';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:laundrivr/src/ble/ble_device_connector.dart';
import 'package:laundrivr/src/data/adapter/ble_adapter.dart';
import 'package:laundrivr/src/data/filter.dart';
import 'package:laundrivr/src/data/machine/ble_data_machine.dart';
import 'package:laundrivr/src/data/machine/data_machine.dart';
import 'package:laundrivr/src/data/machine/empty_data_machine.dart';
import 'package:laundrivr/src/data/utils/ble_constants.dart';
import 'package:laundrivr/src/data/utils/ble_utils.dart';
import 'package:laundrivr/src/data/utils/result/communicator_execution_result.dart';

import '../../ble/ble_device_interactor.dart';
import '../../ble/ble_scanner.dart';
import '../enum/ble_machine_type.dart';
import '../utils/result/data_machine_result.dart';

class BleCommunicatorAdapter4 extends BleAdapter {
  // NOTES: ble is always scanning, we just listen when we want to

  /// Ble scanner (singleton)
  final BleScanner _bleScanner = BleScanner();

  /// Ble connector (singleton)
  final BleDeviceConnector _bleDeviceConnector = BleDeviceConnector();

  /// Ble device interactor (singleton)
  final BleDeviceInteractor _bleDeviceInteractor = BleDeviceInteractor();

  /// Ble scanner subscription (singleton)
  late StreamSubscription<BleScannerState> _bleScannerSubscription;

  /// Ble connection state subscription
  late StreamSubscription<ConnectionStateUpdate>
      _bleConnectionStateSubscription;

  /// Ble characteristic notification subscription
  late StreamSubscription<List<int>> _bleCharacteristicNotificationSubscription;

  /// Data machine
  late DataMachine _bleDataMachine = EmptyDataMachine();

  /// If we found a device
  bool _didFindDevice = false;

  /// Target machine type
  late BleMachineType _targetMachineType;

  /// Target device
  late DiscoveredDevice _targetDevice;

  Future<CommunicatorExecutionResult> execute(
      EndsWithFilter targetMachineNameEnding) async {
    // tell the scanner to start scanning
    _bleScanner.startScan([]);

    // start listening to the scan subscription
    _bleScannerSubscription = _bleScanner.state.listen((event) async {
      List<DiscoveredDevice> discoveredDevices = event.discoveredDevices;
      // for (var value in discoveredDevices) {
      //   log("Found device: ${value.name}");
      // }
      // log the number of devices found
      log("Found ${discoveredDevices.length} devices");
      if (!discoveredDevices
          .any((element) => targetMachineNameEnding.call(element.name))) {
        return;
      }

      // the target machine has been found, stop scanning
      await _bleScanner.stopScan();

      // we found a device, update the flag
      _didFindDevice = true;

      // get the target device
      DiscoveredDevice targetDevice = discoveredDevices
          .firstWhere((element) => targetMachineNameEnding.call(element.name));

      // log that we found a device
      log('Found target device: ${targetDevice.name}, ${targetDevice.id}');

      // cancel the scan subscription
      _bleScannerSubscription.cancel();

      // connect to the target machine
      await _bleDeviceConnector.connect(targetDevice.id);

      // start listening to the connection state subscription
      _bleConnectionStateSubscription =
          _bleDeviceConnector.state.listen((event) async {
        if (event.connectionState == DeviceConnectionState.connected) {
          // the target machine has been connected, stop listening to the connection state subscription
          _bleConnectionStateSubscription.cancel();

          // set the target device
          _targetDevice = targetDevice;

          // start listening to the service discovery subscription
          List<DiscoveredService> services =
              await _bleDeviceInteractor.discoverServices(targetDevice.id);

          // log all the services
          for (var value in services) {
            log("service: ${value.serviceId}");
            // log all the characteristics
            for (var value2 in value.characteristics) {
              log(" -- characteristic: ${value2.characteristicId}");
            }
          }

          // determine the type of the machine based on the service uuid
          BleMachineType machineType = services.any((element) =>
                  element.serviceId == BleConstants.me51ServiceUuid)
              ? BleMachineType.typeMe51
              : BleMachineType.type2;

          // log machine type
          log("Machine type: $machineType");

          // set the target machine type
          _targetMachineType = machineType;

          // initialize the data machine
          _bleDataMachine = BleDataMachine(this);

          // start listening to the characteristic notification subscription
          _bleCharacteristicNotificationSubscription = _bleDeviceInteractor
              .subScribeToCharacteristic(
                  BleUtils.determineNotifyCharacteristicByType(
                      machineType, targetDevice))
              .listen((event) {
            // log that we received a notification
            log('Received data from characteristic notification: $event');
            // call the on receive data callback in the data machine
            _bleDataMachine.onReceiveData(event);
          });

          // start the data machine
          _bleDataMachine.start();
        }
      });
    });

    // LISTEN TO THE SCAN SUBSCRIPTION
    //  // IF >> target device name matches filter
    //  //  // CONNECT TO THE DEVICE
    //  // ELSE >> target device name does not match filter
    //  //  // DO NOTHING

    // WAIT 5 SECONDS
    // // IF >> the device was found
    // //  // DO NOTHING
    // // ELSE >> the device was not found
    // //  // CANCEL ALL SUBSCRIPTIONS
    // //  // SHOW DIALOG THAT THE DEVICE WAS NOT FOUND

    await Future.delayed(const Duration(seconds: 20));

    _cancelAllSubscriptions();

    if (!_didFindDevice) {
      // satisfy the future with an error
      return CommunicatorExecutionResult(
        anErrorOccurred: true,
        laundryMachineWasFound: false,
        couldConnectToLaundryMachine: false,
        associatedErrorMessage: 'Could not find the device',
      );
    } else {
      // if the data machine is not a BleDataMachine, throw an error
      if (_bleDataMachine is! BleDataMachine ||
          _bleDataMachine.isPlaceholder()) {
        // satisfy the future with an error
        return CommunicatorExecutionResult(
          anErrorOccurred: true,
          laundryMachineWasFound: false,
          couldConnectToLaundryMachine: false,
          associatedErrorMessage: 'Could not find the device',
        );
      }

      // get the result from the data machine
      bool didCompleteSuccessfulTransaction =
          _bleDataMachine.didCompleteSuccessfulTransaction();
      int numberOfRetries = _bleDataMachine.getNumOfRetries();

      // construct the result
      DataMachineResult result = DataMachineResult(
        numberOfRetries,
        didCompleteSuccessfulTransaction,
      );

      // return the result
      return CommunicatorExecutionResult(
        anErrorOccurred: false,
        laundryMachineWasFound: true,
        couldConnectToLaundryMachine: true,
        dataMachineResult: result,
      );
    }
  }

  @override
  void endTransaction() {
    _cancelAllSubscriptions();
  }

  @override
  Future<void> write(List<List<int>> data) async {
    // loop through the data
    for (List<int> datum in data) {
      // log that we are writing data
      await _bleDeviceInteractor.writeCharacteristicWithoutResponse(
          BleUtils.determineWriteCharacteristicByType(
              _targetMachineType, _targetDevice),
          datum);
    }
  }

  void _cancelAllSubscriptions() {
    // log that we are cancelling all subscriptions
    log('Cancelling all subscriptions');
    try {
      _bleScanner.stopScan();
    } catch (e) {
      log('Error while stopping scan: $e');
    }

    try {
      _bleScannerSubscription.cancel();
    } catch (e) {
      // ignore
    }

    try {
      _bleConnectionStateSubscription.cancel();
    } catch (e) {
      // ignore
    }

    try {
      _bleCharacteristicNotificationSubscription.cancel();
    } catch (e) {
      // ignore
    }
  }

  void dispose() {
    // cancel all subscriptions
    _cancelAllSubscriptions();
  }
}
