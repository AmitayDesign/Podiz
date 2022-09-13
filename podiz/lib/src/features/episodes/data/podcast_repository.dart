import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firestore_podcast_repository.dart';

final podcastRepositoryProvider = Provider<PodcastRepository>(
  (ref) => FirestorePodcastRepository(
      firestore: ref.watch(firestoreProvider),
      functions: ref.watch(functionsProvider),
      spotifyApi: ref.watch(spotifyApiProvider),
      mixPanelRepository: ref.watch(mixPanelRepository)),
);

abstract class PodcastRepository {
  Stream<Podcast> watchPodcast(String podcastId);
  Future<Podcast> fetchPodcast(String podcastId);
  Future<void> refetchPodcast(String podcastId);
  Future<void> refetchFavoritePodcasts(String userId);
  Query<Podcast> podcastsFirestoreQuery(String filter); //!
  Future<void> follow(String userId, String podcastId);
  Future<void> unfollow(String userId, String podcastId);
}

final podcastStreamProvider = StreamProvider.family<Podcast, String>(
  (ref, podcastId) {
    final podcastRepository = ref.watch(podcastRepositoryProvider);
    return podcastRepository.watchPodcast(podcastId);
  },
);

final podcastFutureProvider = FutureProvider.family<Podcast, String>(
  (ref, podcastId) {
    final podcastRepository = ref.watch(podcastRepositoryProvider);
    return podcastRepository.fetchPodcast(podcastId);
  },
);
