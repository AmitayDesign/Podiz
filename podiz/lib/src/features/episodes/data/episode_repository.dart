import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';

import 'firestore_episode_repository.dart';

final episodeRepositoryProvider = Provider<EpisodeRepository>(
  (ref) => FirestoreEpisodeRepository(
    spotifyApi: ref.watch(spotifyApiProvider),
    firestore: ref.watch(firestoreProvider),
  ),
);

abstract class EpisodeRepository {
  Future<Episode> fetchEpisode(String episodeId);
}
