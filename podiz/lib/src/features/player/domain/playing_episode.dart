import 'package:podiz/src/features/episodes/domain/episode.dart';

class PlayingEpisode extends Episode {
  final Duration initialPosition;
  final bool isPlaying;
  final double playbackSpeed;

  @override
  List<Object> get props => [id, isPlaying, initialPosition, playbackSpeed];

  PlayingEpisode(
      {required String id,
      required String name,
      required String description,
      required Duration duration,
      required String showId,
      required String? imageUrl,
      required String releaseDate,
      required List<String> usersWatching,
      required int commentsCount,
      required this.initialPosition,
      required this.isPlaying,
      required this.playbackSpeed})
      : super(
          id: id,
          name: name,
          description: description,
          duration: duration,
          showId: showId,
          imageUrl: imageUrl,
          releaseDate: releaseDate,
          usersWatching: usersWatching,
          commentsCount: commentsCount,
        );

  factory PlayingEpisode.fromEpisode(
    Episode episode, {
    required Duration position,
    required bool isPlaying,
    required double playbackSpeed,
  }) =>
      PlayingEpisode(
        id: episode.id,
        name: episode.name,
        description: episode.description,
        duration: episode.duration,
        showId: episode.showId,
        imageUrl: episode.imageUrl,
        usersWatching: episode.usersWatching,
        releaseDate: episode.releaseDate,
        commentsCount: episode.commentsCount,
        initialPosition: position,
        isPlaying: isPlaying,
        playbackSpeed: playbackSpeed,
      );
}
