import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final podcastManagerProvider = Provider<PodcastManager>(
  (ref) => PodcastManager(ref.read),
);

class PodcastManager {
  final Reader _read;

  AuthManager get authManager => _read(authManagerProvider);
  ShowManager get showManager => _read(showManagerProvider);

  get userStream => _read(userStreamProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  Map<String, Podcast> podcastBloc = {};

  PodcastManager(this._read) {}

  // General Functions

  resetManager() async {
    podcastBloc = {};
  }

  Future<void> getDevices(String userID) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("devices")
        .call({"userUid": userID});
    print("devices");
  }

  Future<void> fetchUserPlayer(String userID) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("fetchUserPlayer")
        .call({"userUid": userID});
    print(result.data);
    //{"uid: String
    // isPlaying: bool
    // position : int
    //"}
    //procurar o podcast e dps por a aparecer no player com o state e a position!
  }

  Future<Podcast> getPodcastFromFirebase(String episodeId) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await firestore.collection("podcasts").doc(episodeId).get();
    Podcast episode = Podcast.fromJson(doc.data()!);
    episode.uid = episodeId;
    return episode;
  }

  SearchResult? getSearchResultById(String podcastId) {
    if (podcastBloc.containsKey(podcastId)) {
      Podcast podcast = podcastBloc[podcastId]!;
      return SearchResult(
        uid: podcast.uid!,
        name: podcast.name,
        description: podcast.description,
        duration_ms: podcast.duration_ms,
        show_name: podcast.show_name,
        show_uri: podcast.show_uri,
        image_url: podcast.image_url,
        comments: podcast.comments,
        commentsImg: podcast.commentsImg,
        release_date: podcast.release_date,
        watching: podcast.watching,
      );
    }
    return null;
  }

  Future<List<SearchResult>> searchEpisode(String text) async {
    QuerySnapshot<Map<String, dynamic>> docs = await firestore
        .collection("podcasts")
        .where("name", isGreaterThanOrEqualTo: text)
        .get();
    List<SearchResult> result = [];
    for (int i = 0; i < docs.docs.length; i++) {
      Podcast episode = Podcast.fromJson(docs.docs[i].data());
      result.add(podcastToSearchResult(episode));
    }

    return result;
  }

  Future<Podcast> getLastListenedEpisodeFromFirebase() async {
    String uid = authManager.userBloc!.lastListened;
    DocumentSnapshot<Map<String, dynamic>> doc =
        await firestore.collection("podcasts").doc(uid).get();
    return Podcast.fromJson(doc.data()!);
  }

  fetchFeedList() {}

  List<Podcast> getMyCast() {
    List<String> favEpisodes = showManager.getFavoritePodcasts();
    return favEpisodes.map((e) => podcastBloc[e]!).toList();
  }

  Podcast? getRandomEpisode(List<String> episodesId) {
    // return podcastBloc[episodesId[0]]!;
    if (episodesId.isEmpty) {
      return null;
    }
    int index = Random().nextInt(episodesId.length);
    Podcast result = podcastBloc[episodesId[index]]!;
    return result;
  }

  List<Podcast> getHotLive() {
    //query data base
    // return feedList.sublist(0, 40);
    return [];
  }

  SearchResult podcastToSearchResult(Podcast episode) {
    return SearchResult(
        uid: episode.uid!,
        name: episode.name,
        description: episode.description,
        duration_ms: episode.duration_ms,
        show_name: episode.show_name,
        show_uri: episode.show_uri,
        image_url: episode.image_url,
        comments: episode.comments,
        commentsImg: episode.commentsImg,
        release_date: episode.release_date,
        watching: episode.watching);
  }
}
