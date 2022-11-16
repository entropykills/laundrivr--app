class Filter<T> {
  Filter(this._filter);

  final bool Function(T) _filter;

  bool call(T value) => _filter(value);
}

// A filter that accepts a string and returns true if the string contains the
class ContainsFilter extends Filter<String> {
  ContainsFilter(String substring)
      : super((String value) => value.contains(substring));
}
