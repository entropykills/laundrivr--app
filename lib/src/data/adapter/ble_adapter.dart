import '../model/communicator_execution_result.dart';
import '../model/filter.dart';

abstract class BleAdapter {
  void write(List<List<int>> data);

  void endTransaction();

  void satisfyTransaction(CommunicatorExecutionResult result);

  Future<CommunicatorExecutionResult> execute(Filter<String> machineFilter);
}
