import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/player_time.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';
import 'package:podiz/src/utils/instances.dart';

import 'spotify_player_repository.dart';

final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => SpotifyPlayerRepository(
    spotifyApi: ref.watch(spotifyApiProvider),
    functions: ref.watch(functionsProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
    mixPanelRepository: ref.watch(mixPanelRepository),
  ),
);

abstract class PlayerRepository {
  Stream<PlayingEpisode?> watchPlayingEpisode();
  Future<PlayingEpisode?> fetchPlayingEpisode();
  Future<void> play(String episodeId, [Duration? time]);
  Future<void> resume(String episodeId, [Duration? time]);
  Future<void> pause();
  Future<void> fastForward([Duration time = const Duration(seconds: 30)]);
  Future<void> rewind([Duration time = const Duration(seconds: 30)]);
  Future<void> seekTo(Duration time);
  //! create a new file for this
  Stream<bool> connectionChanges();
}

PlayingEpisode? episodePlaying;
//* Providers

final connectionChangesProvider = StreamProvider<bool>(
  (ref) => ref.watch(playerRepositoryProvider).connectionChanges(),
);

final playerStateChangesProvider = StreamProvider<PlayingEpisode?>(
  (ref) async* {
    final connected = ref.watch(connectionChangesProvider).valueOrNull ?? false;
    print('###connected: $connected');
    if (connected) {
      yield* ref.watch(playerRepositoryProvider).watchPlayingEpisode();
    } else {
      if (episodePlaying == null) {
        yield null;
      } else {
        yield PlayingEpisode.fromEpisode(
          episodePlaying!,
          position: episodePlaying!.initialPosition,
          isPlaying: false,
          playbackSpeed: episodePlaying!.playbackSpeed,
        );
      }
    }
  },
);

final firstPlayerFutureProvider = FutureProvider<PlayingEpisode?>(
  (ref) => ref.read(playerStateChangesProvider.future),
);

final playerTimeStreamProvider = StreamProvider.autoDispose<PlayerTime>(
  (ref) async* {
    final episode = ref.watch(playerStateChangesProvider).valueOrNull;
    if (episode == null) {
      episodePlaying = episode;
      yield PlayerTime.zero;
      return;
    }

    final duration = episode.duration;
    if (!episode.isPlaying) {
      episodePlaying = episode;
      yield PlayerTime(duration: duration, position: episode.initialPosition);
    } else {
      final refreshRate = 1 / episode.playbackSpeed;
      final refreshRateInMs = (refreshRate * 1000).toInt();
      yield* Stream.periodic(
        Duration(milliseconds: refreshRateInMs),
        (tick) {
          var position = episode.initialPosition + Duration(seconds: tick + 1);
          if (position > duration) position = duration;
          print('###pos: $position');
          episodePlaying = PlayingEpisode.fromEpisode(
            episode,
            position: position,
            isPlaying: episode.isPlaying,
            playbackSpeed: episode.playbackSpeed,
          );
          return PlayerTime(
            duration: episode.duration,
            position: position,
          );
        },
      );
    }
  }
);

// final playerTimeStreamProvider = StreamProvider.autoDispose<PlayerTime>(
//   (ref) async* {
//     final episode = ref.watch(playerStreamProvider).valueOrNull;
//     print('###duration: ${episode?.duration}');
//     print('###pos2: ${episode?.initialPosition}');
//     episodePlaying = episode;
//     // from episode -> player time;
//     if (episode == null) {
//       yield PlayerTime.zero;
//     } else {
//       yield PlayerTime(
//         duration: episode.duration,
//         position: episode.initialPosition,
//       );
//     }
//   },
// );
