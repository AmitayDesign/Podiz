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
  ),
);

abstract class EpisodeRepository {
  Stream<Episode> watchEpisode(String episodeId);
  Future<Episode> fetchEpisode(String episodeId);
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
