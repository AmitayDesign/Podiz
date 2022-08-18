import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firestore_podcast_repository.dart';

final podcastRepositoryProvider = Provider<PodcastRepository>(
  (ref) => FirestorePodcastRepository(
    spotifyApi: ref.watch(spotifyApiProvider),
    firestore: ref.watch(firestoreProvider),
  ),
);

abstract class PodcastRepository {
  Future<Podcast> fetchPodcast(String podcastId);
  Query<Podcast> podcastsFirestoreQuery(String filter); //!
}

final podcastFutureProvider = FutureProvider.family<Podcast, String>(
  (ref, podcastId) {
    final podcastRepository = ref.watch(podcastRepositoryProvider);
    return podcastRepository.fetchPodcast(podcastId);
  },
);
