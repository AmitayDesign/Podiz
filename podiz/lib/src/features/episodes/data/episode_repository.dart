import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firestore_episode_repository.dart';

final episodeRepositoryProvider = Provider<EpisodeRepository>(
  (ref) => FirestoreEpisodeRepository(
    spotifyApi: ref.watch(spotifyApiProvider),
    firestore: ref.watch(firestoreProvider),
    functions: ref.watch(functionsProvider),
  ),
);

abstract class EpisodeRepository {
  Stream<Episode> watchEpisode(String episodeId);
  Future<Episode> fetchEpisode(String episodeId);
  Future<Episode?> fetchLastShowEpisode(String showId);
  Query<Episode> showEpisodesFirestoreQuery(String showId);
  Query<Episode> hotliveFirestoreQuery(); //!
  Query<Episode> episodesFirestoreQuery(String filter); //!
}

final episodeStreamProvider = StreamProvider.family<Episode, String>(
  (ref, episodeId) {
    final episodeRepository = ref.watch(episodeRepositoryProvider);
    return episodeRepository.watchEpisode(episodeId);
  },
);

final episodeFutureProvider = FutureProvider.family<Episode, String>(
  (ref, episodeId) {
    final episodeRepository = ref.watch(episodeRepositoryProvider);
    return episodeRepository.fetchEpisode(episodeId);
  },
);

final lastShowEpisodeFutureProvider = FutureProvider.family<Episode?, String>(
  (ref, showId) {
    final episodeRepository = ref.watch(episodeRepositoryProvider);
    return episodeRepository.fetchLastShowEpisode(showId);
  },
);
