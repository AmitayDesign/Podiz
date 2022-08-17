import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'player_repository.dart';

class SpotifyPlayerRepository implements PlayerRepository {
  final EpisodeRepository episodeRepository;

  SpotifyPlayerRepository({required this.episodeRepository});

  @override
  Stream<PlayingEpisode?> watchPlayingEpisode() =>
      SpotifySdk.subscribePlayerState().asyncMap(playingEpisodeFromPlayerState);

  @override
  Future<PlayingEpisode?> fetchPlayingEpisode() async {
    final state = await SpotifySdk.getPlayerState();
    if (state == null) return null;
    return playingEpisodeFromPlayerState(state);
  }

  Future<PlayingEpisode?> playingEpisodeFromPlayerState(
      PlayerState state) async {
    final track = state.track;
    if (track == null || !track.isEpisode || !track.isPodcast) return null;
    final episode = await episodeRepository.fetchEpisode(track.uri);
    return PlayingEpisode.fromEpisode(
      episode,
      position: state.playbackPosition,
      isPlaying: !state.isPaused,
    );
  }

  //TODO add seconds to resume instead
  @override
  Future<void> play(String episodeId, [int? seconds]) async {
    if (seconds != null) {
      await SpotifySdk.seekTo(positionedMilliseconds: seconds);
      return resume(episodeId);
    }
    return SpotifySdk.play(spotifyUri: episodeId);
  }

  @override
  Future<void> resume(String episodeId) async {
    try {
      await SpotifySdk.resume();
    } catch (_) {
      await play(episodeId);
    }
  }

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

  @override
  Future<void> seekTo(int seconds) {
    final position = Duration(seconds: seconds).inMilliseconds;
    return SpotifySdk.seekTo(positionedMilliseconds: position);
  }
}
