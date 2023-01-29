class Filter<T> {
  Filter(this._filter);

  final bool Function(T) _filter;

  bool call(T value) => _filter(value);
}

class ClassicMachineFilter extends Filter<String> {
  ClassicMachineFilter(String substring)
      : super((String value) =>
            value.length == 18 && value.substring(15, 18) == substring);
}

class OtherMachineFilter extends Filter<String> {
  OtherMachineFilter(String substring)
      : super((String value) =>
            value.length == 18 && value.substring(9, 15) == substring);
}
