import '../filter.dart';
import '../utils/result/communicator_execution_result.dart';

abstract class BleAdapter {
  void write(List<List<int>> data);

  void endTransaction();

  void satisfyTransaction(CommunicatorExecutionResult result);

  Future<CommunicatorExecutionResult> execute(
      EndsWithFilter targetMachineNameEnding);
}
