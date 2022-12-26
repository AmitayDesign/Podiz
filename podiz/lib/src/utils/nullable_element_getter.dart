extension NullableElementGetter<T> on Iterable<T> {
  T? elementAtOrNull(int index) {
    try {
      return elementAt(index);
    } catch (_) {
      return null;
    }
  }
}
