abstract class DataMachine {
  void onReceiveData(List<int> data);

  void start();

  bool isPlaceholder();

  bool didCompleteSuccessfulTransaction();

  bool didRun();

  int getNumOfRetries();
}
