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
  //TODO watch episode
  Future<Episode> fetchEpisode(String episodeId);
  Query<Episode> hotliveFirestoreQuery(); //!
  Query<Episode> episodesFirestoreQuery(String filter); //!
}

final episodeFutureProvider =
    FutureProvider.family.autoDispose<Episode, EpisodeId>(
  (ref, episodeId) async {
    final episodeRepository = ref.watch(episodeRepositoryProvider);
    final episode = await episodeRepository.fetchEpisode(episodeId);
    ref.keepAlive();
    return episode;
  },
);
