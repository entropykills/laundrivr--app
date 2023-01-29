import 'package:laundrivr/src/data/model/data_machine_result.dart';

class CommunicatorExecutionResult {
  late bool _anErrorOccurred;
  late bool _laundryMachineWasFound;
  late bool _couldConnectToLaundryMachine;
  late DataMachineResult? _dataMachineResult;
  late String? _associatedErrorMessage;

  CommunicatorExecutionResult(
      {required bool anErrorOccurred,
      required bool laundryMachineWasFound,
      required bool couldConnectToLaundryMachine,
      DataMachineResult? dataMachineResult,
      String? associatedErrorMessage}) {
    _anErrorOccurred = anErrorOccurred;
    _laundryMachineWasFound = laundryMachineWasFound;
    _couldConnectToLaundryMachine = couldConnectToLaundryMachine;
    _dataMachineResult = dataMachineResult;
    _associatedErrorMessage = associatedErrorMessage;
  }

  bool get anErrorOccurred => _anErrorOccurred;

  bool get laundryMachineWasFound => _laundryMachineWasFound;

  bool get couldConnectToLaundryMachine => _couldConnectToLaundryMachine;

  DataMachineResult? get dataMachineResult => _dataMachineResult;

  String? get associatedErrorMessage => _associatedErrorMessage;
}
