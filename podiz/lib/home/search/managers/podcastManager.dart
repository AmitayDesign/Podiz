import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/providers.dart';

final podcastManagerProvider = Provider.autoDispose<PodcastManager>(
  (ref) {
    final manager = PodcastManager(
      authManager: ref.watch(authManagerProvider),
      showManager: ref.watch(showManagerProvider),
      firestore: ref.watch(firestoreProvider),
    );
    return manager;
  },
);

class PodcastManager {
  final AuthManager authManager;
  final ShowManager showManager;
  final FirebaseFirestore firestore;

  PodcastManager({
    required this.authManager,
    required this.showManager,
    required this.firestore,
  });

  Future<void> getDevices(String userID) async {
    //TODO verify result
    await FirebaseFunctions.instance
        .httpsCallable("devices")
        .call({"userUid": userID});
    print("devices");
  }

  Future<Podcast> fetchPodcast(String episodeId) async {
    final doc = await firestore.collection("podcasts").doc(episodeId).get();
    return Podcast.fromFirestore(doc);
  }

  Future<Podcast?> getRandomEpisode(List<String> episodeIds) async {
    // return podcastBloc[episodeIds[0]]!;
    if (episodeIds.isEmpty) return null;
    final index = Random().nextInt(episodeIds.length);
    final episodeId = episodeIds[index];
    return await fetchPodcast(episodeId);
  }

  Query<Podcast> hotliveFirestoreQuery() => FirebaseFirestore.instance
      .collection("podcasts")
      .orderBy("release_date", descending: true)
      .withConverter(
        fromFirestore: (doc, _) => Podcast.fromFirestore(doc),
        toFirestore: (podcast, _) => {},
      );

  Query<SearchResult> podcastsFirestoreQuery(String filter) =>
      FirebaseFirestore.instance
          .collection("podcasts")
          .where("searchArray", arrayContains: filter.toLowerCase())
          .withConverter(
            fromFirestore: (doc, _) {
              Podcast podcast = Podcast.fromFirestore(doc);
              return SearchResult.fromPodcast(podcast);
            },
            toFirestore: (podcast, _) => {},
          );
}
