import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/player_time.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';

import 'spotify_player_repository.dart';

final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => SpotifyPlayerRepository(
      episodeRepository: ref.watch(episodeRepositoryProvider),
      mixPanelRepository: ref.watch(mixPanelRepository)),
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
}

//* Providers

final playerStateChangesProvider = StreamProvider<PlayingEpisode?>(
  (ref) async* {
    final connected = ref.watch(connectionChangesProvider).valueOrNull;
    if (connected != true) yield null;
    yield* ref.watch(playerRepositoryProvider).watchPlayingEpisode();
  },
);

final firstPlayerFutureProvider = FutureProvider<PlayingEpisode?>(
  (ref) => ref.read(playerStateChangesProvider.future),
);

final playerTimeStreamProvider = StreamProvider.autoDispose<PlayerTime>(
  (ref) async* {
    final episode = ref.watch(playerStateChangesProvider).valueOrNull;
    if (episode == null) {
      yield PlayerTime.zero;
      return;
    }
    // player has an episode
    final duration = episode.duration;
    if (!episode.isPlaying) {
      yield PlayerTime(duration: duration, position: episode.initialPosition);
    } else {
      final refreshRate = 1 / episode.playbackSpeed;
      final refreshRateInMs = (refreshRate * 1000).toInt();
      yield* Stream.periodic(
        Duration(milliseconds: refreshRateInMs),
        (tick) {
          var position = episode.initialPosition + Duration(seconds: tick + 1);
          if (position > duration) position = duration;
          return PlayerTime(duration: duration, position: position);
        },
      );
    }
  },
);
