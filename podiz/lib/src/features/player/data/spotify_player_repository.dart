import 'dart:io';

import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/utils/uri_from_id.dart';
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
    final episodeId = idFromUri(track.uri);
    // fetch episode
    var episode = await episodeRepository.fetchEpisode(episodeId);
    return PlayingEpisode.fromEpisode(
      episode,
      position: Duration(milliseconds: state.playbackPosition),
      isPlaying: !state.isPaused,
      playbackSpeed: state.playbackSpeed,
    );
  }

  @override
  Future<void> play(String episodeId, [Duration? time]) async {
    await SpotifySdk.play(spotifyUri: uriFromId(episodeId));
    if (time != null) {
      await SpotifySdk.seekTo(positionedMilliseconds: time.inMilliseconds);
    }
  }

  @override
  Future<void> resume(String episodeId, [Duration? time]) async {
    try {
      if (time != null) {
        await SpotifySdk.seekTo(positionedMilliseconds: time.inMilliseconds);
      }
      await SpotifySdk.resume();
    } catch (_) {
      await play(episodeId, time);
    }
  }

  @override
  Future<void> pause() => SpotifySdk.pause();

  @override
  Future<void> fastForward([Duration time = const Duration(seconds: 30)]) =>
      seekToRelativePosition(time);

  @override
  Future<void> rewind([Duration time = const Duration(seconds: 30)]) =>
      seekToRelativePosition(-time);

  Future<void> seekToRelativePosition(Duration time) async {
    if (Platform.isIOS) {
      final state = await SpotifySdk.getPlayerState();
      final position = state?.playbackPosition ?? 0;
      return SpotifySdk.seekTo(
        positionedMilliseconds: position + time.inMilliseconds,
      );
    }
    return SpotifySdk.seekToRelativePosition(
      relativeMilliseconds: time.inMilliseconds,
    );
  }

  @override
  Future<void> seekTo(Duration time) =>
      SpotifySdk.seekTo(positionedMilliseconds: time.inMilliseconds);
}
