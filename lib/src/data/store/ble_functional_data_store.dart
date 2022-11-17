import 'dart:typed_data';

class BleFunctionalDataStore {
  /// The type of CSCSW machine that is being communicated with
  /// The length is going to be 1 byte, always
  /// According to discovered information:
  /// Type "1": KioSoft Ultra LX Pro
  /// Type "2": CleanReader Connect (Card Reader) or CleanReader Solo Connect (App Only)
  late List<int> machineType = Uint8List(1);

  /// The price it costs (in cents) to use the machine
  /// This price can either be a top off price or the full load price, depending on the data received from the machine
  /// Two bytes in length... for $1.50, the data  will be 0x00 0x96
  /// For $1.25, the data will be 0x00 0x7D
  /// The 0x7D will show up as a right bracket in ascii... look out for that!
  late List<int> vendPrice = Uint8List(2);

  ///The money required to do a "pulse"
  /// The definition of pulse is unknown, and it's something referred to in related CSCSW code
  String pulseMoney = "";

  /// If the start button is enabled
  bool startButtonIsEnabled = false;

  /// If the start button is pressed
  bool startButtonIsPressed = false;

  /// If the machine can do a top off
  bool canDoTopOff = false;

  /// If the machine can do a super cycle
  bool canDoSuperCycle = false;
}
