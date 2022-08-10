import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/providers.dart';

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

  ShowManager(this._read);

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

  Future<List<SearchResult>> searchShow(String text) async {
    QuerySnapshot<Map<String, dynamic>> docs = await firestore
        .collection("podcasters")
        .where("name", isGreaterThanOrEqualTo: text)
        .get();
    List<SearchResult> result = [];
    for (int i = 0; i < docs.docs.length; i++) {
      Podcaster show = Podcaster.fromJson(docs.docs[i].data());
      result.add(podcasterToSearchResult(show));
    }

    return result;
  }

  Future<Podcaster> getShowFromFirebase(String showUid) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await firestore.collection("podcasters").doc(showUid).get();
    Podcaster show = Podcaster.fromJson(doc.data()!);
    show.uid = showUid;
    return show;
  }

  List<String> getFavoritePodcasts() {
    return favShow;
  }

  SearchResult podcasterToSearchResult(Podcaster show) {
    return SearchResult(
        uid: show.uid!,
        name: show.name,
        description: show.description,
        image_url: show.image_url,
        publisher: show.publisher,
        total_episodes: show.total_episodes,
        podcasts: show.podcasts,
        followers: show.followers);
  }
}
