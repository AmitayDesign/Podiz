class PlayerTime {
  /// Episode id
  final String? episodeId;

  /// Player position in seconds
  final Duration position;

  /// Episode duration in seconds
  final Duration duration;

  const PlayerTime({
    required this.episodeId,
    required this.duration,
    required this.position,
  });

  static PlayerTime get zero => const PlayerTime(
        episodeId: null,
        duration: Duration(seconds: 1),
        position: Duration.zero,
      );

  PlayerTime copyWith({required Duration position}) {
    return PlayerTime(
      episodeId: episodeId,
      position: position,
      duration: duration,
    );
  }
}
