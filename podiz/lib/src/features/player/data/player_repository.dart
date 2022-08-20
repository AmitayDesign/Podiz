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
  Future<void> play(String episodeId, [Duration? time]);
  Future<void> resume(String episodeId, [Duration? time]);
  Future<void> pause();
  Future<void> fastForward([Duration time = const Duration(seconds: 30)]);
  Future<void> rewind([Duration time = const Duration(seconds: 30)]);
  Future<void> seekTo(Duration time);
}

//* Providers

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
    final duration = Duration(milliseconds: episode.duration);
    // player has an episode
    if (!episode.isPlaying) {
      yield PlayerTime(duration: duration, position: episode.initialPosition);
    } else {
      yield* Stream.periodic(
        const Duration(seconds: 1),
        (tick) => PlayerTime(
          duration: duration,
          position: episode.initialPosition + Duration(seconds: tick + 1),
        ),
      );
    }
  },
);
