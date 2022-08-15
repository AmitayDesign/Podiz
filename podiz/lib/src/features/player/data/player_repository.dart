import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/player.dart';

import 'spotify_player_repository.dart';

final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => SpotifyPlayerRepository(
    episodeRepository: ref.watch(episodeRepositoryProvider),
  ),
);

abstract class PlayerRepository {
  Stream<Player?> playerStateChanges();
  Future<Player?> currentPlayerState();
  Future<void> play(String podcastId);
  Future<void> resume();
  Future<void> pause();
  Future<void> fastForward([int seconds = 30]);
  Future<void> rewind([int seconds = 30]);
}

//* Providers

final playerStateChangesProvider = StreamProvider<Player?>(
  (ref) => ref.watch(playerRepositoryProvider).playerStateChanges(),
);

//TODO when pausing, pause timer
final playerTimeProvider = StreamProvider.autoDispose<int>(
  (ref) async* {
    final player = ref.watch(playerStateChangesProvider).valueOrNull;
    if (player == null) {
      yield 0;
    } else if (!player.isPlaying) {
      yield player.playbackPosition;
    } else {
      final position = player.playbackPosition;
      final timeUntilPreciseSecond = position % 1000;
      await Future.delayed(Duration(milliseconds: timeUntilPreciseSecond));
      yield* Stream.periodic(
        const Duration(seconds: 1),
        (tick) => player.playbackPosition + (tick + 2) * 1000,
      );
    }
  },
);
