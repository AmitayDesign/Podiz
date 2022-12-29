import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';
import 'package:podiz/src/utils/in_memory_store.dart';
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
  }) {
    listenToConnectionChanges();
  }

  void dispose() {
    connectionSub?.cancel();
  }

  PlayingEpisode? lastPlayingEpisode;

  @override
  bool get isConnected => connectionState.value;

  final connectionState = InMemoryStore<bool>(false);
  StreamSubscription? connectionSub;
  void listenToConnectionChanges() {
    connectionSub?.cancel();
    connectionSub =
        SpotifySdk.subscribeConnectionStatus().listen((status) async {
      connectionState.value = status.connected;
      // on android, when user is logged in, keep connecting if
      // if(Platform.isAndroid){
      //   if (!status.connected && currentUser?.id != null) {
      //       spotifyApi.fetchAccessToken();
      //     }
      // }
    });
  }

  @override
  Stream<PlayingEpisode?> watchPlayingEpisode() =>
      SpotifySdk.subscribePlayerState()
          .asyncMap(playingEpisodeFromPlayerState)
          .handleError((e) => lastPlayingEpisode);

  @override
  Future<PlayingEpisode?> fetchPlayingEpisode() async {
    if (!isConnected) {
      await spotifyApi.connectToSdk();
    }
    final state = await SpotifySdk.getPlayerState();
    if (state == null) return null;
    return playingEpisodeFromPlayerState(state);
  }

  Future<PlayingEpisode?> playingEpisodeFromPlayerState(
      PlayerState state) async {
    final track = state.track;
    if (track == null) return null;
    if (!track.isEpisode || !track.isPodcast) {
      pause();
      return null;
    }
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
    print("###PLAY");
    print(isConnected);
    mixPanelRepository.userOpenPodcast();
    if (!isConnected) {
      await spotifyApi.connectToSdk();
    }
    await SpotifySdk.play(spotifyUri: uriFromId(episodeId));
    if (time != null) await seekTo(time);
  }

  @override
  Future<void> resume(String episodeId, [Duration? time]) async {
    try {
      print("###RESUME");
      print(isConnected);
      if (time != null) await seekTo(time);
      if (!isConnected) {
        await spotifyApi.connectToSdk();
      }
      await SpotifySdk.resume();
    } catch (_) {
      await play(episodeId, time);
    }
  }

  @override
  Future<void> pause() async {
    print("###PAUSE");
    print(isConnected);
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
      if (!isConnected) {
        await spotifyApi.connectToSdk();
      }
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
    if (!isConnected) {
      await spotifyApi.connectToSdk();
    }
    return SpotifySdk.seekTo(positionedMilliseconds: time.inMilliseconds);
  }

  //! SPOTIFY CONNECTION CHANGES

  @override
  Stream<bool> connectionChanges() =>
      SpotifySdk.subscribeConnectionStatus().map((status) => status.connected);
}
