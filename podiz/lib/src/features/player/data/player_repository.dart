import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/player_time.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';

import 'spotify_player_repository.dart';

final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => SpotifyPlayerRepository(
    episodeRepository: ref.watch(episodeRepositoryProvider),
  ),
);

abstract class PlayerRepository {
  Stream<PlayingEpisode?> watchPlayingEpisode();
  Future<PlayingEpisode?> fetchPlayingEpisode();
  Future<void> play(String episodeId, [int? seconds]);
  Future<void> resume(String episodeId, [int? seconds]);
  Future<void> pause();
  Future<void> fastForward([int seconds = 30]);
  Future<void> rewind([int seconds = 30]);
  Future<void> seekTo(int seconds);
}

//* Providers

//TODO add load state while searching for episode
final playerStateChangesProvider = StreamProvider<PlayingEpisode?>(
  (ref) => ref.watch(playerRepositoryProvider).watchPlayingEpisode(),
);

final playerTimeStreamProvider = StreamProvider.autoDispose<PlayerTime>(
  (ref) async* {
    final episode = ref.watch(playerStateChangesProvider).valueOrNull;
    if (episode == null) {
      yield PlayerTime.zero;
      return;
    }
    // player has an episode
    if (!episode.isPlaying) {
      yield PlayerTime(
        duration: episode.duration ~/ 1000,
        position: episode.initialPosition ~/ 1000,
      );
    } else {
      final initialPosition = episode.initialPosition;
      final timeUntilPreciseSecond = 1000 - initialPosition % 1000;
      await Future.delayed(Duration(milliseconds: timeUntilPreciseSecond));
      yield* Stream.periodic(
        const Duration(seconds: 1),
        (tick) {
          final position =
              (initialPosition + timeUntilPreciseSecond) + (tick + 1) * 1000;
          return PlayerTime(
            duration: episode.duration ~/ 1000,
            position: position ~/ 1000,
          );
        },
      );
    }
  },
);
