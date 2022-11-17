import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleConstants {
  static final Guid type2ServiceGuid =
      Guid("0000ffe0-0000-1000-8000-00805f9b34fb");
  static final Guid type2CharWriteGuid =
      Guid("0000ffe1-0000-1000-8000-00805f9b34fb");
  static final Guid type2CharNotifyGuid =
      Guid("0000ffe1-0000-1000-8000-00805f9b34fb");

  static final Guid me51CharNotifyGuid =
      Guid("49535343-1E4D-4BD9-BA61-23C647249616");
  static final Guid me51CharWriteGuid =
      Guid("49535343-8841-43F4-A8D4-ECBE34729BB3");
  static final Guid me51CharServiceGuid =
      Guid("49535343-fe7d-4ae5-8fa9-9fafd205e455");
}
