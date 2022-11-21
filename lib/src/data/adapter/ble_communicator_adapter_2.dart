import 'dart:developer';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:laundrivr/src/data/enum/ble_machine_type.dart';
import 'package:laundrivr/src/data/utils/ble_constants.dart';
import 'package:laundrivr/src/data/utils/result/data_machine_result.dart';

import '../filter.dart';
import '../machine/ble_data_machine.dart';
import '../utils/result/ble_machine_execution_result.dart';
import 'ble_adapter.dart';

class BleCommunicatorAdapter2 extends BleAdapter {
  static final FlutterReactiveBle _ble = FlutterReactiveBle();

  bool _foundMachine = false;

  late Function(BleMachineExecutionResult) _callback;

  /// The data machine
  late BleDataMachine _dataMachine;

  /// The machine type
  late BleMachineType _machineType;

  /// The target device
  late DiscoveredDevice _targetDevice;

  /// If the ble is initialized
  bool _isInitialized = false;

  /// If the ble is scanning
  bool _isScanning = false;

  Future<void> execute(Filter<String> targetMachineDigitsFilter,
      Function(BleMachineExecutionResult) callback) async {
    _callback = callback;

    // if not initialized, initialize
    if (!_isInitialized) {
      await _ble.initialize();
      _isInitialized = true;
    }

    // if already scanning, call the callback with an error
    if (_isScanning) {
      _callback(BleMachineExecutionResult(
          anErrorOccurred: true,
          couldNotFindMachine: false,
          couldNotConnectToMachine: false,
          errorMessage: "Already scanning"));
      return;
    }

    // start scanning
    _isScanning = true;

    _ble.scanForDevices(withServices: [
      BleConstants.me51CharServiceUuid,
      BleConstants.type2ServiceUuid,
    ], scanMode: ScanMode.lowLatency).listen((device) {
      // log the device name
      log("Found device: ${device.name}");

      // if the device is not the target machine, ignore it
      if (!targetMachineDigitsFilter.call(device.name)) {
        return;
      }

      // update the found machine flag
      _foundMachine = true;

      // call the on found machine method
      _onFoundMachine(device);
    }, onError: (error) {
      // call the callback with an error
      callback(BleMachineExecutionResult(
        anErrorOccurred: true,
        couldNotConnectToMachine: true,
        couldNotFindMachine: false,
        errorMessage: error.toString(),
      ));
    });

    // wait for 5 seconds to accommodate for the scan
    await Future.delayed(const Duration(seconds: 5));

    // if the machine was not found, call the callback with an error
    if (!_foundMachine) {
      callback(BleMachineExecutionResult(
        anErrorOccurred: true,
        couldNotConnectToMachine: false,
        couldNotFindMachine: true,
        errorMessage: "The machine was not found",
      ));
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
    // determine the type of the machine based on the service uuid
    BleMachineType machineType = device.serviceUuids
            .any((element) => element == BleConstants.me51CharServiceUuid)
        ? BleMachineType.typeMe51
        : BleMachineType.type2;

    // connect to the machine
    _ble
        .connectToAdvertisingDevice(
      id: device.id,
      prescanDuration: const Duration(seconds: 5),
      withServices: determineServices(machineType),
      connectionTimeout: const Duration(seconds: 2),
      servicesWithCharacteristicsToDiscover:
          determineServicesAndCharacteristics(
        machineType,
      ),
    )
        .listen((connectionStateUpdate) {
      // log the connection state update
      log("Connection state update: ${connectionStateUpdate.connectionState}");
      // if the connection state is connected, call the on connected method
      if (connectionStateUpdate.connectionState ==
          DeviceConnectionState.connected) {
        _onConnectedToMachine(device, machineType);
      }
    }, onError: (Object error) {
      // call the callback with an error
      _callback(BleMachineExecutionResult(
        anErrorOccurred: true,
        couldNotConnectToMachine: true,
        couldNotFindMachine: false,
        errorMessage: error.toString(),
      ));
    });
  }

  /// Called when the client is connected to the machine
  void _onConnectedToMachine(DiscoveredDevice device, BleMachineType type) {
    // create the data machine
    _dataMachine = BleDataMachine(this);

    // subscribe to the notify characteristic
    _ble
        .subscribeToCharacteristic(
      determineTargetNotifyCharacteristic(device, type),
    )
        .listen((value) {
      // call the on data received method
      _dataMachine.onReceiveData(value);
    }, onError: (Object error) {
      // call the callback with an error
      _callback(BleMachineExecutionResult(
        anErrorOccurred: true,
        couldNotConnectToMachine: true,
        couldNotFindMachine: false,
        errorMessage: error.toString(),
      ));
    });
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
  }

  /// Called when the data machine needs to send data
  @override
  void write(List<List<int>> data) {
    // write the data to the write characteristic by looping through the chunks
    for (var element in data) {
      _ble.writeCharacteristicWithResponse(
        determineTargetWriteCharacteristic(_targetDevice, _machineType),
        value: element,
      );
    }
  }
}
