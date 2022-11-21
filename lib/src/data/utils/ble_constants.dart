import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleConstants {
  static final Uuid type2ServiceUuid =
      Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb");
  static final Uuid type2CharWriteUuid =
      Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");
  static final Uuid type2CharNotifyUuid =
      Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");

  static final Uuid type2CharWriteUuid16 = Uuid.parse("ffe1");
  static final Uuid type2CharNotifyUuid16 = Uuid.parse("ffe1");
  static final Uuid type2ServiceUuid16 = Uuid.parse("ffe0");

  static final Uuid me51CharNotifyUuid =
      Uuid.parse("49535343-1E4D-4BD9-BA61-23C647249616");
  static final Uuid me51CharWriteUuid =
      Uuid.parse("49535343-8841-43F4-A8D4-ECBE34729BB3");
  static final Uuid me51ServiceUuid =
      Uuid.parse("49535343-fe7d-4ae5-8fa9-9fafd205e455");

  static final Uuid me51CharWriteUuid16 = Uuid.parse("5343");
  static final Uuid me51CharNotifyUuid16 = Uuid.parse("5343");
  static final Uuid me51ServiceUuid16 = Uuid.parse("5343");
}
