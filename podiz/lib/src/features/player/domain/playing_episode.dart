import 'package:podiz/src/features/episodes/domain/episode.dart';

class PlayingEpisode extends Episode {
  final int initialPosition;
  final bool isPlaying;

  PlayingEpisode({
    required String id,
    required String name,
    required String description,
    required Duration duration,
    required String showId,
    required String imageUrl,
    required String releaseDate,
    required List<String> usersWatching,
    required this.initialPosition,
    required this.isPlaying,
  }) : super(
          id: id,
          name: name,
          description: description,
          duration: duration,
          showId: showId,
          imageUrl: imageUrl,
          releaseDate: releaseDate,
          usersWatching: usersWatching,
        );

  factory PlayingEpisode.fromEpisode(
    Episode episode, {
    required int position,
    required bool isPlaying,
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
        initialPosition: position,
        isPlaying: isPlaying,
      );
}
