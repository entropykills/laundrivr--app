import 'dart:developer';
import 'dart:typed_data';

class CscswUtils {
  /// Calculates the longitude redundancy check for the given data
  /// param data: the data to calculate the LRC for
  /// returns: the LRC for the given data
  static int calculateLRC(List<int> data) {
    int lrc = 0;
    for (int datum in data) {
      lrc ^= datum;
    }

    return lrc;
  }

  /// Formats a packet for sending to a CSCSW machine
  /// Adapted from a CSCSW algorithm
  /// param data: the data to format
  /// param packetType: the type of packet to send, known by the CSCSW machine
  /// returns: the formatted packet
  static List<int> formatPacket(List<int> data, String packetType) {
    int var2 = 7 + data.length;
    int var3 = 0;
    int var4 = data.length;

    List<int> var5 = Uint8List(var2);
    List<int> var6 = Uint8List(var4 + 4);
    var5[0] = 2;
    int var7 = var4 + 2;
    int var8 = ((int.parse('ff00', radix: 16) & var7) >> 8);
    var5[1] = var8;
    var6[0] = var8;
    var8 = (var7 & 255);
    var5[2] = var8;
    var6[1] = var8;
    List<int> var9 = packetType.codeUnits;
    var5[3] = var9[0];
    var6[2] = var9[0];
    var5[4] = var9[1];

    for (var6[3] = var9[1]; var3 < var4; ++var3) {
      var8 = data[var3];
      var5[var3 + 5] = var8;
      var6[var3 + 4] = var8;
    }

    var5[var2 - 2] = calculateLRC(var6);
    var5[var2 - 1] = 3;
    return var5;
  }

  /// Splits a packet into equally sized chunks of a given size
  /// Adapted from a CSCSW algorithm
  /// param data: the packet to split
  /// param chunkSize: the size of each chunk
  /// returns: the split packet
  static List<List<int>> splitBytesIntoChunks(List<int> data, int chunkSize) {
    // if the data is less than the chunk size, return the data
    if (data.length <= chunkSize) {
      return [data];
    }

    // create a list of lists to hold the chunks
    List<List<int>> chunks = [];
    // loop through the data
    for (int i = 0; i < data.length; i += chunkSize) {
      // if the new chunk is less than the chunk size, add the rest of the data
      if (i + chunkSize > data.length) {
        chunks.add(data.sublist(i));
      } else {
        // otherwise, add the chunk
        chunks.add(data.sublist(i, i + chunkSize));
      }
    }
    // return the list of chunks
    return chunks;
  }

  /// Converts a byte array to a hex string
  /// param data: the byte array to convert
  /// returns: the hex string
  static String convertBytesToHexString(List<int> data) {
// create a string buffer to hold the hex string
    StringBuffer buffer = StringBuffer();
    // loop through the data
    for (int datum in data) {
      // convert the byte to a hex string
      String hex = datum.toRadixString(16);
      // if the hex string is only one character long, add a leading zero
      if (hex.length == 1) {
        hex = '0$hex';
      }
      // add the hex string to the buffer
      buffer.write(hex);
    }
    // return the hex string
    return buffer.toString();
  }

  /// Gets the completed packet length from data received from a CSCSW machine
  /// param constructedPacket: the data received from the machine
  /// returns: the length of the completed packet
  static int getCompletePacketLengthFromData(List<int> constructedPacket) {
    int secondByte = constructedPacket[1];
    return constructedPacket[2] & 255 | secondByte << 8;
  }

  /// Converts a hex string to a byte array
  /// Adapted from <a href="https://stackoverflow.com/a/140861"/>a stackoverflow post</a>,
  /// param hexString: the hex string to convert
  /// returns: the byte array
  static List<int> convertHexStringToByteArray(String hexString) {
    // create a list to hold the bytes
    List<int> bytes = [];
    // loop through the hex string
    for (int i = 0; i < hexString.length; i += 2) {
      // convert the hex string to a byte
      int byte = int.parse(hexString.substring(i, i + 2), radix: 16);
      // add the byte to the list
      bytes.add(byte);
    }
    // return the list of bytes
    return bytes;
  }

  /// Converts a byte array to a hex string
  /// param data: the byte array to convert
  /// returns: the hex string
  static String convertByteArrayToHexString(List<int> data) {
    // create a string buffer to hold the hex string
    StringBuffer buffer = StringBuffer();
    // loop through the data
    for (int datum in data) {
      // convert the byte to a hex string
      String hex = datum.toRadixString(16);
      // if the hex string is only one character long, add a leading zero
      if (hex.length == 1) {
        hex = '0$hex';
      }
      // add the hex string to the buffer
      buffer.write(hex);
    }
    // return the hex string
    return buffer.toString();
  }

  /// Returns the price of vending/pulsing (unknown) from a packet
  /// param packet: the packet to get the price from
  /// returns: the price of vending/pulsing (unknown)
  static String getPriceFromPacket(List<int> packet) {
    List<int> var1 = Uint8List(2);

    for (int var2 = 0; var2 < 2; ++var2) {
      var1[var2] = packet[var2 + 6];
    }

    // wrap var1 in a byte buffer and get the short
    ByteBuffer byteBuffer = Uint8List.fromList(var1).buffer;
    ByteData byteData = ByteData.view(byteBuffer);
    int var3 = byteData.getUint16(0);
    // return the byte as a string
    return var3.toString();
  }

  static List<int> copyOfRange(
      List<int> src, int srcPos, List<int> dest, int destPos, int length) {
    // to ensure the length doesn't exceeds limit
    // length+2 because, it targets on the end index, that is 4 in source list
    // but the end result should be length+2 to contain a length of 5 items
    if (length + 1 <= src.length - 1) {
      dest = src.sublist(srcPos, length + 2);
    } else {
      log('Cannot copy items till $length: index out of bound');
    }

    return dest;
  }
}
