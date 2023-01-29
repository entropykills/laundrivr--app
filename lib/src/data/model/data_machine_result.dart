class DataMachineResult {
  final int numberOfRetries;
  final bool didCompleteSuccessfulTransaction;

  DataMachineResult(
      this.numberOfRetries, this.didCompleteSuccessfulTransaction);
}
