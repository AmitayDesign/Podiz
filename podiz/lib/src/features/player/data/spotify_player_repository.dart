import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';
import 'package:podiz/src/utils/uri_from_id.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'player_repository.dart';

class SpotifyPlayerRepository implements PlayerRepository {
  final SpotifyApi spotifyApi;
  final FirebaseFunctions functions;
  final EpisodeRepository episodeRepository;
  final MixPanelRepository mixPanelRepository;

  SpotifyPlayerRepository({
    required this.spotifyApi,
    required this.functions,
    required this.episodeRepository,
    required this.mixPanelRepository,
  });

  @override
  Stream<PlayingEpisode?> watchPlayingEpisode() =>
      SpotifySdk.subscribePlayerState().asyncMap(playingEpisodeFromPlayerState);

  @override
  Future<PlayingEpisode?> fetchPlayingEpisode() async {
    final state = await SpotifySdk.getPlayerState()
        .timeout(Duration(seconds: 1), onTimeout: () async {
      await spotifyApi.connectToSdk();
      return await SpotifySdk.getPlayerState();
    });
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
    mixPanelRepository.userOpenPodcast();

    await SpotifySdk.play(spotifyUri: uriFromId(episodeId))
        .timeout(Duration(seconds: 1), onTimeout: (() async {
      await spotifyApi.connectToSdk();
      await SpotifySdk.play(spotifyUri: uriFromId(episodeId));
    }));
    if (time != null) await seekTo(time);
  }

  @override
  Future<void> resume(String episodeId, [Duration? time]) async {
    try {
      if (time != null) await seekTo(time);
      await SpotifySdk.resume().timeout(
        Duration(seconds: 1),
        onTimeout: () async {
          await play(episodeId, time);
        },
      );
    } catch (_) {
      await play(episodeId, time);
    }
  }

  @override
  Future<void> pause() async {
    await SpotifySdk.pause();
  }

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
      return seekTo(Duration(milliseconds: position + time.inMilliseconds));
    }
    return SpotifySdk.seekToRelativePosition(
      relativeMilliseconds: time.inMilliseconds,
    );
  }

  @override
  Future<void> seekTo(Duration time) async {
    return SpotifySdk.seekTo(positionedMilliseconds: time.inMilliseconds)
        .timeout(
      Duration(seconds: 1),
      onTimeout: () async {
        await spotifyApi.connectToSdk();
        SpotifySdk.seekTo(positionedMilliseconds: time.inMilliseconds);
      },
    );
  }
}
