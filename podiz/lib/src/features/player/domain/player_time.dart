class PlayerTime {
  final int position;
  final int duration;

  const PlayerTime({
    required this.duration,
    required this.position,
  });

  static PlayerTime get zero => const PlayerTime(duration: 1, position: 0);
}
