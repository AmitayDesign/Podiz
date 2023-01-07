extension DateDifference on DateTime {
  /// Returns an [int] with the difference (in full days)
  /// when subtracting [other] from [this].
  /// The returned [int] will be negative if [other] occurs after [this].
  int differenceInDays(DateTime other) {
    final date = DateTime(year, month, day);
    final today = DateTime(other.year, other.month, other.day);
    return date.difference(today).inDays;
  }
}
