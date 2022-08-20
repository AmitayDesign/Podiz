import 'package:podiz/src/features/episodes/domain/episode.dart';

class PlayingEpisode extends Episode {
  final Duration initialPosition;
  final bool isPlaying;

  PlayingEpisode({
    required String id,
    required String name,
    required String description,
    required int duration,
    required String showName,
    required String showId,
    required String imageUrl,
    required int commentsCount,
    required List<String> commentImageUrls,
    required String releaseDateString,
    required List<String> userIdsWatching,
    required this.initialPosition,
    required this.isPlaying,
  }) : super(
          id: id,
          name: name,
          description: description,
          duration: duration,
          showName: showName,
          showId: showId,
          imageUrl: imageUrl,
          commentsCount: commentsCount,
          commentImageUrls: commentImageUrls,
          releaseDateString: releaseDateString,
          userIdsWatching: userIdsWatching,
        );

  factory PlayingEpisode.fromEpisode(
    Episode episode, {
    required Duration position,
    required bool isPlaying,
  }) =>
      PlayingEpisode(
        id: episode.id,
        name: episode.name,
        description: episode.description,
        duration: episode.duration,
        showName: episode.showName,
        showId: episode.showId,
        imageUrl: episode.imageUrl,
        commentsCount: episode.commentsCount,
        commentImageUrls: episode.commentImageUrls,
        releaseDateString: episode.releaseDateString,
        userIdsWatching: episode.userIdsWatching,
        initialPosition: position,
        isPlaying: isPlaying,
      );
}
