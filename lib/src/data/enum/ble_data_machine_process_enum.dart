enum DataMachineProcess {
  start(0),
  vendorId(1),
  getPrice(2),
  startCycleExtend(3);

  final int value;

  const DataMachineProcess(this.value);
}
