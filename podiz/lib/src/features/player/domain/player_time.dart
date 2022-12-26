class PlayerTime {
  /// Player position in seconds
  final Duration position;

  /// Episode duration in seconds
  final Duration duration;

  const PlayerTime({required this.duration, required this.position});

  static PlayerTime get zero => const PlayerTime(
        duration: Duration(seconds: 1),
        position: Duration.zero,
      );
}
