import 'dart:async';
import 'dart:developer';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:laundrivr/src/ble/ble_device_connector.dart';
import 'package:laundrivr/src/ble/ble_device_interactor.dart';
import 'package:laundrivr/src/data/adapter/ble_adapter.dart';

import '../../ble/ble_scanner.dart';
import '../enum/ble_machine_type.dart';
import '../filter.dart';
import '../machine/ble_data_machine.dart';
import '../utils/ble_constants.dart';
import '../utils/result/ble_machine_execution_result.dart';
import '../utils/result/data_machine_result.dart';

class BleCommunicatorAdapter3 extends BleAdapter {
  bool _foundMachine = false;

  late Function(BleMachineExecutionResult) _callback;

  /// The data machine
  late BleDataMachine _dataMachine;

  /// The machine type
  late BleMachineType _machineType;

  /// The target device
  late DiscoveredDevice _targetDevice;

  /// Ble scanner
  final BleScanner _bleScanner = BleScanner();

  // Ble device connector
  final BleDeviceConnector _bleDeviceConnector = BleDeviceConnector();

  // Ble device interactor
  final BleDeviceInteractor _bleDeviceInteractor = BleDeviceInteractor();

  /// Subscription
  late StreamSubscription<BleScannerState> _scannerSubscription;

  /// Subscription
  late StreamSubscription<ConnectionStateUpdate> _connectionSubscription;

  /// Subscription
  late StreamSubscription<List<int>> _notificationSubscription;

  Future<void> _cancelScanSubscription() async {
    await _scannerSubscription.cancel();
  }

  Future<void> _cancelConnectionSubscription() async {
    await _connectionSubscription.cancel();
  }

  Future<void> _cancelNotificationSubscription() async {
    await _notificationSubscription.cancel();
  }

  Future<void> execute(Filter<String> targetMachineDigitsFilter,
      Function(BleMachineExecutionResult) callback) async {
    _callback = callback;

    // start scanning
    _bleScanner.startScan(
        [BleConstants.me51CharServiceUuid, BleConstants.type2ServiceUuid]);

    // listen to scan results
    _scannerSubscription = _bleScanner.state.listen((event) async {
      // if we already found the machine, don't do anything
      if (_foundMachine) {
        return;
      }
      // if the target machine is not found, continue scanning
      if (!event.discoveredDevices
          .any((element) => targetMachineDigitsFilter.call(element.name))) {
        return;
      }

      // if the target machine is found, stop scanning
      await _bleScanner.stopScan();

      // end the subscription to the scan results
      await _cancelScanSubscription();

      // update the found machine flag
      _foundMachine = true;

      // log that the machine is found
      log("FOUND MACHINE");

      // call the on found machine method
      _onFoundMachine(event.discoveredDevices.firstWhere(
          (element) => targetMachineDigitsFilter.call(element.name)));
    });

    // wait for 5 seconds to accommodate for the scan
    await Future.delayed(const Duration(seconds: 5));

    // if the machine was not found, call the callback with an error
    if (!_foundMachine) {
      _callback(BleMachineExecutionResult(
        anErrorOccurred: true,
        couldNotConnectToMachine: false,
        couldNotFindMachine: true,
        errorMessage: "The machine was not found (timeout)",
      ));
    }

    try {
      // stop scanning
      await _bleScanner.stopScan();
      // end the subscription to the scan results
      await _cancelScanSubscription();
    } catch (e) {
      // ignore
    }
  }

  /// Determines the target write characteristic based on the machine type
  QualifiedCharacteristic determineTargetWriteCharacteristic(
      DiscoveredDevice device, BleMachineType machineType) {
    switch (machineType) {
      case BleMachineType.typeMe51:
        return QualifiedCharacteristic(
          serviceId: BleConstants.me51CharServiceUuid,
          characteristicId: BleConstants.me51CharWriteUuid,
          deviceId: device.id,
        );
      case BleMachineType.type2:
        return QualifiedCharacteristic(
          serviceId: BleConstants.type2ServiceUuid,
          characteristicId: BleConstants.type2CharWriteUuid,
          deviceId: device.id,
        );
    }
  }

  /// Determines the target notify characteristic based on the machine type
  QualifiedCharacteristic determineTargetNotifyCharacteristic(
      DiscoveredDevice device, BleMachineType machineType) {
    switch (machineType) {
      case BleMachineType.typeMe51:
        return QualifiedCharacteristic(
          serviceId: BleConstants.me51CharServiceUuid,
          characteristicId: BleConstants.me51CharNotifyUuid,
          deviceId: device.id,
        );
      case BleMachineType.type2:
        return QualifiedCharacteristic(
          serviceId: BleConstants.type2ServiceUuid,
          characteristicId: BleConstants.type2CharNotifyUuid,
          deviceId: device.id,
        );
    }
  }

  /// Determines the target services based on the machine type
  List<Uuid> determineServices(BleMachineType machineType) {
    switch (machineType) {
      case BleMachineType.typeMe51:
        return [BleConstants.me51CharServiceUuid];
      case BleMachineType.type2:
        return [BleConstants.type2ServiceUuid];
      default:
        return [];
    }
  }

  /// Determines the services and characteristics to use for the target machine
  Map<Uuid, List<Uuid>> determineServicesAndCharacteristics(
      BleMachineType machineType) {
    switch (machineType) {
      case BleMachineType.typeMe51:
        return {
          BleConstants.me51CharServiceUuid: [
            BleConstants.me51CharWriteUuid,
            BleConstants.me51CharNotifyUuid,
          ],
        };
      case BleMachineType.type2:
        return {
          BleConstants.type2ServiceUuid: [
            BleConstants.type2CharWriteUuid,
            // BleConstants.type2CharNotifyUuid,
          ],
        };
    }
  }

  /// Called when the machine is found
  Future<void> _onFoundMachine(DiscoveredDevice device) async {
    // log calling the on found machine method
    log("CALLING ON FOUND MACHINE");

    // determine the type of the machine based on the service uuid
    BleMachineType machineType = device.serviceUuids
            .any((element) => element == BleConstants.me51CharServiceUuid)
        ? BleMachineType.typeMe51
        : BleMachineType.type2;

    // update the machine type
    _machineType = machineType;

    // listen to connection state updates
    _connectionSubscription = _bleDeviceConnector.state.listen((event) {
      // if the connection state is disconnected, call the callback with an error
      if (event.connectionState == DeviceConnectionState.connected) {
        _onConnectedToMachine(device, machineType);
      } else if (event.connectionState == DeviceConnectionState.disconnected) {
        // call the end method
        endTransaction();
      }
    });

    await _bleDeviceConnector
        .connect(device.id)
        .onError((error, stackTrace) => {
              // log
              _callback(BleMachineExecutionResult(
                anErrorOccurred: true,
                couldNotConnectToMachine: true,
                couldNotFindMachine: false,
                errorMessage: "Could not connect to the machine (on found)",
              )),
              // cancel the connection subscription
              _cancelConnectionSubscription(),
            });
  }

  /// Called when the client is connected to the machine
  void _onConnectedToMachine(DiscoveredDevice device, BleMachineType type) {
    // initialize the target device
    _targetDevice = device;

    // log that the client is connected to the machine
    log("CONNECTED TO MACHINE");

    // create the data machine
    _dataMachine = BleDataMachine(this);

    // subscribe to the notify characteristic
    _notificationSubscription = _bleDeviceInteractor
        .subScribeToCharacteristic(
            determineTargetNotifyCharacteristic(device, type))
        .listen((event) {
      // log the received data
      log("RECEIVED DATA: ${event}");
      _dataMachine.onReceiveData(event);
    });
    _notificationSubscription
        .onError((e) => _callback(BleMachineExecutionResult(
              anErrorOccurred: true,
              couldNotConnectToMachine: true,
              couldNotFindMachine: false,
              errorMessage:
                  "Could not connect to the machine (notif): ${e.toString()}",
            )));

    // start the data machine
    _dataMachine.start();
  }

  /// Called when the data machine is done
  @override
  void endTransaction() {
    // if an error occurred, call the callback with an error
    if (!_dataMachine.didRun ||
        !_dataMachine.didCompleteSuccessfulTransaction) {
      _callback(BleMachineExecutionResult(
          anErrorOccurred: true,
          couldNotConnectToMachine: false,
          couldNotFindMachine: false,
          errorMessage:
              "The transaction ${_dataMachine.didCompleteSuccessfulTransaction ? "was successful" : "failed"}",
          dataMachineResult: DataMachineResult(_dataMachine.numberOfRetries,
              _dataMachine.didCompleteSuccessfulTransaction)));
    } else {
      // call the callback with success
      _callback(BleMachineExecutionResult(
        anErrorOccurred: false,
        couldNotConnectToMachine: false,
        couldNotFindMachine: false,
      ));
    }

    try {
      // cancel the connection subscription
      _cancelConnectionSubscription();
      // cancel the scan subscription
      _cancelScanSubscription();
      // cancel the notification subscription
      _cancelNotificationSubscription();
    } catch (e) {
      // ignore
    }
  }

  /// Called when the data machine needs to send data
  @override
  void write(List<List<int>> data) {
    // write the data to the write characteristic by looping through the chunks
    // try catch block to catch any errors
    try {
      for (var element in data) {
        _bleDeviceInteractor.writeCharacteristicWithResponse(
            determineTargetWriteCharacteristic(_targetDevice, _machineType),
            element);
      }
    } catch (e) {
      // call the callback with an error
      _callback(BleMachineExecutionResult(
        anErrorOccurred: true,
        couldNotConnectToMachine: false,
        couldNotFindMachine: false,
        errorMessage: "An error occurred while writing to the machine",
      ));
    }
  }
}
