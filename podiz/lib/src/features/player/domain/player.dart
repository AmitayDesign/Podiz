import 'package:podiz/src/features/episodes/domain/episode.dart';

class Player {
  final EpisodeId episodeId;
  final String episodeName;
  final String episodeImageUrl;
  final int episodeDuration;

  final int playbackPosition;
  final bool isPlaying;

  Player({
    required this.episodeId,
    required this.episodeName,
    required this.episodeImageUrl,
    required this.episodeDuration,
    required this.playbackPosition,
    required this.isPlaying,
  });
}
