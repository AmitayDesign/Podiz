import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final showManagerProvider = Provider<ShowManager>(
  (ref) => ShowManager(ref.read),
);

class ShowManager {
  final Reader _read;

  get userStream => _read(userStreamProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);
  AuthManager get authManager => _read(authManagerProvider);

  Map<String, Podcaster> showBloc = {};
  List<String> favShow = [];

  ShowManager(this._read) {}

  // General Functions

  String getRandomEpisode(List<String> episodesId) {
    int index = Random().nextInt(episodesId.length);
    return episodesId[index];
  }

  resetManager() async {
    // await podcastStreamSubscription?.cancel();
    // await productsStream?.close();
    showBloc = {};
  }

  List<String>? getEpisodes(String showId) {
    if (showBloc.containsKey(showId)) {
      return showBloc[showId]!.podcasts;
    }
    return null;
  }

  String? getShowImageUrl(String showId) {
    if (showBloc.containsKey(showId)) {
      return showBloc[showId]!.image_url;
    }
    return null;
  }

  searchShow(String text) async {
    QuerySnapshot<Map<String, dynamic>> docs = await firestore
        .collection("podcasters")
        .where("name", isGreaterThanOrEqualTo: text)
        .get();

    // docs.
  }

  List<String> getFavoritePodcasts() {
    return favShow;
  }
}
