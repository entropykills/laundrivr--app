import 'data_machine_result.dart';

class BleMachineExecutionResult {
  final bool anErrorOccurred;
  final bool couldNotFindMachine;
  final bool couldNotConnectToMachine;
  final DataMachineResult? dataMachineResult;
  final String? errorMessage;

  BleMachineExecutionResult({
    required this.anErrorOccurred,
    required this.couldNotFindMachine,
    required this.couldNotConnectToMachine,
    this.dataMachineResult,
    this.errorMessage,
  });
}
