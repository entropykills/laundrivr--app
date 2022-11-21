// import 'dart:developer';
//
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:laundrivr/src/data/filter.dart';
// import 'package:laundrivr/src/data/machine/ble_data_machine.dart';
// import 'package:laundrivr/src/data/utils/ble_constants.dart';
// import 'package:laundrivr/src/data/utils/cscsw_constants.dart';
//
// import './ble_adapter.dart';
// import '../machine/ble_machine_execution_result.dart';
//
// /// A class that contains the logic for adapting BLE
// class BleCommunicatorAdapter implements Adapter<FlutterBluePlus> {
//   /// The singleton instance of this class
//   static final BleCommunicatorAdapter _singleton =
//       BleCommunicatorAdapter._internal();
//
//   BleCommunicatorAdapter._internal();
//
//   static final FlutterBluePlus _ble = FlutterBluePlus.instance;
//
//   /// A filter to filter out device names of type 1
//   static final Filter<String> _typeTwoMachineNameFilter =
//       ContainsFilter(CscswConstants.typeTwoBLENameBeginning);
//
//   /// If FlutterBluePlus is currently scanning
//   bool _scanning = false;
//
//   /// define target guids
//   late Guid _targetServiceGuid;
//   late Guid _targetCharWriteGuid;
//   late Guid _targetCharNotifyGuid;
//
//   /// define target characteristics and service for communication
//   late BluetoothCharacteristic _targetCharWrite;
//   late BluetoothCharacteristic _targetCharNotify;
//   late BluetoothService _targetService;
//
//   // Define the target device
//   late BluetoothDevice _targetDevice;
//
//   /// The Bluetooth data machine
//   late BleDataMachine _dataMachine = BleDataMachine(this);
//
//   /// Callback
//   late Function _callback;
//
//   // add a constructor
//   factory BleCommunicatorAdapter() {
//     return _singleton;
//   }
//
//   /// A function that forces a disconnect
//   void forceDisconnect() async {
//     // if the target exists and is connected, disconnect
//     if (await _targetDevice.state.first == BluetoothDeviceState.connected) {
//       await _targetDevice.disconnect();
//     }
//   }
//
//   /// Starts the BLE device scanning and functional test
//   Future<void> start(Filter<String> targetMachineDigitsFilter,
//       Function(DataMachineResult) callback) async {
//     // set the callback
//     _callback = callback;
//     // if scanning already, don't do anything
//     if (_scanning) {
//       return;
//     }
//
//     // set scanning to true so we don't start scanning twice
//     _scanning = true;
//
//     // scan for 5 seconds
//     await _ble.startScan(timeout: const Duration(seconds: 5));
//
//     // listen for results and call a callback with the results
//     _ble.scanResults.listen((results) async {
//       // log
//       log("Found device: ${results.first.device.name}");
//
//       // if the results do not contain the target device
//       if (!results
//           .any((element) => targetMachineDigitsFilter(element.device.name))) {
//         // do nothing, since the device hasn't been found yet
//         return;
//       }
//
//       // the device was found, so stop scanning
//       await _stopScanning();
//
//       // get the target device
//       var result = results.firstWhere(
//           (element) => targetMachineDigitsFilter(element.device.name));
//
//       // connect to the device
//       await _connectToDevice(result.device, _onConnection(result.device), () {
//         // if the connection failed, show a dialog
//         /* _showMyDialog('Connection Failed',
//             'Could not connect to the found device. Please try again.');*/
//         // call the callback with a failed result
//         _callback(DataMachineResult(
//             numberOfRetries: 0,
//             didCompleteSuccessfulTransaction: false,
//             foundDevice: true,
//             didFailToConnect: true,
//             didRun: false));
//       });
//     });
//
//     // wait for 5 seconds
//     await Future.delayed(const Duration(seconds: 5));
//
//     if (!_scanning) {
//       // if we're still scanning, then something went wrong
//       if (await _ble.isScanning.first) {
//         // send a dialog message
//         // _showMyDialog(
//         //     'Error', 'Could not find the device, and something went wrong.');
//         // stop scanning
//         await _stopScanning();
//       }
//
//       // if already not scanning, we found the device so we can just return
//       return;
//     }
//
//     // we definitely didn't find the device so let's send some messages
//     log("Device not found!");
//
//     // add a popup
//     // _showMyDialog("Error", "The target device wasn't found.");
//
//     // call the callback with a failed result
//     _callback(DataMachineResult(
//         numberOfRetries: 0,
//         didCompleteSuccessfulTransaction: false,
//         foundDevice: false,
//         didFailToConnect: false,
//         didRun: false));
//
//     // stop scanning
//     await _stopScanning();
//   }
//
//   Future<void> _stopScanning() async {
//     // stop scanning
//     await _ble.stopScan();
//     // set the scanning flag to false
//     _scanning = false;
//   }
//
//   Future<void> _connectToDevice(BluetoothDevice device,
//       Future<void> successCallback, Function errorCallback) async {
//     // set the target device
//     _targetDevice = device;
//     // connect to the device
//     device
//         .connect()
//         .then((value) => successCallback)
//         .onError((error, stackTrace) => errorCallback);
//   }
//
//   Future<void> _onDisconnect(BluetoothDevice device) async {
//     // make sure everything is stopped scanning first
//     await _stopScanning();
//     if (!_dataMachine.didRun) {
//       return;
//     }
//
//     // call the callback
//     _callback(DataMachineResult(
//       numberOfRetries: _dataMachine.numberOfRetries,
//       didCompleteSuccessfulTransaction:
//           _dataMachine.didCompleteSuccessfulTransaction,
//       didRun: _dataMachine.didRun,
//       foundDevice: true,
//       didFailToConnect: false,
//     ));
//
//     // show a dialog saying the transaction was successful
//     // _showMyDialog("Success", "The transaction was successful.");
//     // reinitialize the data machine
//     _dataMachine = BleDataMachine(this);
//   }
//
//   Future<void> _onConnection(BluetoothDevice device) async {
//     // listen for disconnects
//     device.state.listen((event) async {
//       if (event == BluetoothDeviceState.disconnected) {
//         await _onDisconnect(device);
//       }
//     });
//
//     // filter the correct machine characteristics and service
//     if (_typeTwoMachineNameFilter(device.name)) {
//       // set the target characteristics & services
//       _targetServiceGuid = BleConstants.type2ServiceGuid;
//       _targetCharWriteGuid = BleConstants.type2CharWriteGuid;
//       _targetCharNotifyGuid = BleConstants.type2CharNotifyGuid;
//     } else {
//       // set the target characteristics & services
//       _targetServiceGuid = BleConstants.me51CharServiceGuid;
//       _targetCharWriteGuid = BleConstants.me51CharWriteGuid;
//       _targetCharNotifyGuid = BleConstants.me51CharNotifyGuid;
//     }
//
//     // discover all services
//     List<BluetoothService> services = await device.discoverServices();
//
//     // if the target isn't in the services, return
//     if (!services.any((service) => service.uuid == _targetServiceGuid)) {
//       // error message
//       log("Target service not found!");
//       return;
//     }
//
//     // get the target service
//     _targetService =
//         services.firstWhere((service) => service.uuid == _targetServiceGuid);
//
//     // loop all services and see if the target characteristics are in the service, if not, return
//     if (!_targetService.characteristics.any(
//             (characteristic) => characteristic.uuid == _targetCharWriteGuid) ||
//         !_targetService.characteristics.any(
//             (characteristic) => characteristic.uuid == _targetCharNotifyGuid)) {
//       // error message
//       log("A target characteristic was not found!");
//       return;
//     }
//
//     // log that we found the target service
//     log("Target service found!");
//
//     // get the target characteristics
//     _targetCharWrite = _targetService.characteristics.firstWhere(
//         (characteristic) => characteristic.uuid == _targetCharWriteGuid);
//     _targetCharNotify = _targetService.characteristics.firstWhere(
//         (characteristic) => characteristic.uuid == _targetCharNotifyGuid);
//
//     // log that we found the target characteristics
//     log("Target characteristics found!");
//
//     // set the target characteristics to notify
//     await _targetCharNotify.setNotifyValue(true);
//     // create a callback for when the target characteristic is updated
//     _targetCharNotify.value.listen((value) {
//       // handle the value in the data-machine callback
//       _dataMachine.onDataReceived(value);
//     });
//
//     // start the data machine
//     _dataMachine.start();
//   }
//
//   /// Writes the data to the target characteristic
//   Future<void> writeData(List<List<int>> data) async {
//     // loop through each packet and write it
//     for (List<int> packet in data) {
//       // wait for the write request to go through so all data is sent
//       await _targetCharWrite.write(packet, withoutResponse: false);
//     }
//   }
//
//   // /// Provides the adaption of the flutter blue plus instance
//   // @override
//   // FlutterBluePlus provideAdaption() {
//   //   return FlutterBluePlus.instance;
//   // }
// }
