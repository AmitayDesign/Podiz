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
  final SpotifyAPI spotifyApi;
  final FirebaseFunctions functions;
  final EpisodeRepository episodeRepository;
  final MixPanelRepository mixPanelRepository;

  SpotifyPlayerRepository({
    required this.spotifyApi,
    required this.functions,
    required this.episodeRepository,
    required this.mixPanelRepository,
  });

  PlayingEpisode? lastPlayingEpisode;

  @override
  Stream<PlayingEpisode?> watchPlayingEpisode() =>
      SpotifySdk.subscribePlayerState()
          .skipWhile((state) => state.track == null)
          .asyncMap(playingEpisodeFromPlayerState)
          .handleError((e) => lastPlayingEpisode);

  @override
  Future<PlayingEpisode?> fetchPlayingEpisode() async {
    final state = await SpotifySdk.getPlayerState()
        .timeout(const Duration(seconds: 1), onTimeout: () async {
      print('### FETCH');
      await spotifyApi.connectToSdk();
      return await SpotifySdk.getPlayerState();
    });
    if (state == null) return null;
    return playingEpisodeFromPlayerState(state);
  }

  Future<PlayingEpisode?> playingEpisodeFromPlayerState(
      PlayerState state) async {
    final track = state.track;
    if (track == null) return null;
    if (Platform.isIOS && spotifyApi.stopIOSPlayer) {
      spotifyApi.stopIOSPlayer = false;
      if (!track.isEpisode || !track.isPodcast) pause();
    }
    if (!track.isEpisode || !track.isPodcast) return null;
    final episodeId = idFromUri(track.uri);
    // fetch episode
    final stateTime = DateTime.now();
    var episode = await episodeRepository.fetchEpisode(episodeId);
    final futureDuration = DateTime.now().difference(stateTime);
    lastPlayingEpisode = PlayingEpisode.fromEpisode(
      episode,
      position: Duration(milliseconds: state.playbackPosition) + futureDuration,
      isPlaying: !state.isPaused,
      playbackSpeed: state.playbackSpeed,
    );
    return lastPlayingEpisode;
  }

  @override
  Future<void> play(String episodeId, [Duration? time]) async {
    mixPanelRepository.userOpenPodcast();

    await SpotifySdk.play(spotifyUri: uriFromId(episodeId))
        .timeout(const Duration(seconds: 1), onTimeout: (() async {
      print('### PLAYNING');
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
        const Duration(seconds: 1),
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
      const Duration(seconds: 1),
      onTimeout: () async {
        print('### PAUSE');
        await spotifyApi.connectToSdk();
        SpotifySdk.seekTo(positionedMilliseconds: time.inMilliseconds);
      },
    );
  }
}
