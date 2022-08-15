import 'package:podiz/src/features/episodes/domain/episode.dart';

class Player {
  final Episode episode;
  final bool isPlaying;

  final int playbackPosition;

  Player({
    required this.episode,
    required this.isPlaying,
    required this.playbackPosition,
  });
}
