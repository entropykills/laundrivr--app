import 'data_machine.dart';

class EmptyDataMachine extends DataMachine {
  @override
  void onReceiveData(List<int> data) {
    // TODO: implement onReceiveData
  }

  @override
  bool isPlaceholder() {
    return true;
  }

  @override
  bool didCompleteSuccessfulTransaction() {
    // TODO: implement didCompleteSuccessfulTransaction
    throw UnimplementedError();
  }

  @override
  bool didRun() {
    // TODO: implement didRun
    throw UnimplementedError();
  }

  @override
  int getNumOfRetries() {
    // TODO: implement getNumOfRetries
    throw UnimplementedError();
  }

  @override
  void start() {
    // TODO: implement start
    throw UnimplementedError();
  }
}
