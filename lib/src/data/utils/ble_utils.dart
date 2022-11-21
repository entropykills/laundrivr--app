import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:laundrivr/src/data/enum/ble_machine_type.dart';
import 'package:laundrivr/src/data/utils/ble_constants.dart';

class BleUtils {
  static QualifiedCharacteristic determineWriteCharacteristicByType(
      BleMachineType type, DiscoveredDevice device) {
    switch (type) {
      case BleMachineType.type2:
        return QualifiedCharacteristic(
            characteristicId: BleConstants.type2CharWriteUuid16,
            serviceId: BleConstants.type2ServiceUuid16,
            deviceId: device.id);
      case BleMachineType.typeMe51:
        return QualifiedCharacteristic(
            characteristicId: BleConstants.me51CharWriteUuid,
            serviceId: BleConstants.me51ServiceUuid,
            deviceId: device.id);
      default:
        throw Exception("Unknown machine type");
    }
  }

  static QualifiedCharacteristic determineNotifyCharacteristicByType(
      BleMachineType type, DiscoveredDevice device) {
    switch (type) {
      case BleMachineType.type2:
        return QualifiedCharacteristic(
            characteristicId: BleConstants.type2CharNotifyUuid16,
            serviceId: BleConstants.type2ServiceUuid16,
            deviceId: device.id);
      case BleMachineType.typeMe51:
        return QualifiedCharacteristic(
            characteristicId: BleConstants.me51CharNotifyUuid,
            serviceId: BleConstants.me51ServiceUuid,
            deviceId: device.id);
      default:
        throw Exception("Unknown machine type");
    }
  }
}
