import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart';

final podcastManagerProvider = Provider<PodcastManager>(
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
}
