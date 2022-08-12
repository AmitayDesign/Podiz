import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/providers.dart';

final podcastManagerProvider = Provider<PodcastManager>(
  (ref) => PodcastManager(
    firestore: ref.watch(firestoreProvider),
  ),
);

class PodcastManager {
  final FirebaseFirestore firestore;

  PodcastManager({
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
    print(episodeId);
    print(doc.data());
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
