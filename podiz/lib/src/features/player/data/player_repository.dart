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
  Future<void> resume(String episodeId);
  Future<void> pause();
  Future<void> fastForward([int seconds = 30]);
  Future<void> rewind([int seconds = 30]);
  Future<void> seekTo(int seconds);
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
    // player has an episode
    // ref.watch(listeningProvider(episode.id));
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

//TODO test this when closing app
// final listeningProvider = Provider.family.autoDispose<void, EpisodeId>(
//   (ref, episodeId) {
//     print('LISTENING TO $episodeId');
//     final doc =
//         ref.read(firestoreProvider).collection('podcasts').doc(episodeId);
//     const field = 'users_watching';
//     // get the user that's watching
//     final user = ref.read(currentUserProvider);
//     // add new watcher
//     doc.set({
//       field: FieldValue.arrayUnion([user.id])
//     }, SetOptions(merge: true));
//     // remove watcher
//     ref.onDispose(() {
//       print('STOPPED $episodeId');
//       doc.update({
//         field: FieldValue.arrayRemove([user.id])
//       });
//     });
//   },
//   disposeDelay: const Duration(milliseconds: 200),
// );
