import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/player.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'player_repository.dart';

class SpotifyPlayerRepository implements PlayerRepository {
  final EpisodeRepository episodeRepository;

  SpotifyPlayerRepository({required this.episodeRepository});

  @override
  Stream<Player?> playerStateChanges() =>
      SpotifySdk.subscribePlayerState().asyncMap((state) async {
        final track = state.track; //TODO fix null track
        if (track == null || !track.isEpisode || !track.isPodcast) return null;
        final episode = await episodeRepository.fetchEpisode(track.uri);
        return Player(
          episode: episode,
          isPlaying: !state.isPaused,
          playbackPosition: state.playbackPosition,
        );
      });

  @override
  Future<void> play(String podcastId) => SpotifySdk.play(spotifyUri: podcastId);

  @override
  Future<void> resume() => SpotifySdk.resume();

  @override
  Future<void> pause() => SpotifySdk.pause();

  @override
  Future<void> fastForward([int seconds = 30]) {
    final position = Duration(seconds: seconds).inMilliseconds;
    return SpotifySdk.seekToRelativePosition(relativeMilliseconds: position);
  }

  @override
  Future<void> rewind([int seconds = 30]) {
    final position = -Duration(seconds: seconds).inMilliseconds;
    return SpotifySdk.seekToRelativePosition(relativeMilliseconds: position);
  }
}
