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
