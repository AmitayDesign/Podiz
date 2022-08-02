import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
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

  ShowManager get showManager => _read(showManagerProvider);

  get userStream => _read(userStreamProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  Map<String, Podcast> podcastBloc = {};
  List<Podcast> feedList = [];

  final _podcastStream = BehaviorSubject<Map<String, Podcast>>();
  Stream<Map<String, Podcast>> get podcasts => _podcastStream.stream;

  PodcastManager(this._read) {
    firestore
        .collection("podcasts")
        .orderBy("release_date", descending: true)
        .snapshots()
        .listen((snapshot) async {
      //\TODO order this
      for (DocChange podcastChange in snapshot.docChanges) {
        if (podcastChange.type == DocumentChangeType.added) {
          await addPodcastToBloc(podcastChange.doc);
        } else if (podcastChange.type == DocumentChangeType.modified) {
          await editPodcastToBloc(podcastChange.doc);
        }
      }
      _podcastStream.add(podcastBloc);
    });
  }

  // General Functions

  addPodcastToBloc(Doc doc) {
    Podcast podcast = Podcast.fromJson(doc.data()!);
    podcast.uid = doc.id;

    podcastBloc[doc.id] = podcast;
    feedList.add(podcast);
  }

  editPodcastToBloc(Doc doc) {
    Podcast podcast = Podcast.fromJson(doc.data()!);
    podcast.uid = doc.id;
    podcastBloc[doc.id] = podcast;
  }

  resetManager() async {
    // await podcastStreamSubscription?.cancel();
    // await productsStream?.close();
    podcastBloc = {};
  }

  Future<void> getDevices(String userID) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("devices")
        .call({"userUid": userID});
  }

  Podcast getPodcastById(String podcastId) {
    if (podcastBloc.containsKey(podcastId)) {
      Podcast podcast = podcastBloc[podcastId]!;
      return podcast;
    }
    return Podcast("Not_Found",
        name: "Not_Found",
        description: "Not_Found",
        duration_ms: 0,
        show_name: "Not_Found",
        show_uri: "Not_Found",
        image_url: "Not_Found",
        comments: 0,
        commentsImg: [],
        release_date: "",
        watching: 0);
  }

  SearchResult getSearchResultById(String podcastId) {
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
    return SearchResult(
        uid: "Not_Found",
        name: "Not_Found",
        description: "Not_Found",
        duration_ms: 0,
        show_name: "Not_Found",
        show_uri: "Not_Found",
        image_url: "Not_Found",
        comments: 0,
        commentsImg: [],
        release_date: "",
        watching: 0);
  }

  List<Podcast> getMyCast() {
    List<String> favEpisodes = showManager.getFavoritePodcasts();
    return favEpisodes.map((e) => podcastBloc[e]!).toList();
  }

  Podcast getRandomEpisode(List<String> episodesId) {
    // return podcastBloc[episodesId[0]]!;
    if (episodesId.isEmpty) {
      return emptyPodcast();
    }
    int index = Random().nextInt(episodesId.length);
    Podcast result = podcastBloc[episodesId[index]]!;
    return result;
  }

  List<Podcast> getHotLive() {
    return feedList.sublist(0, 40);
  }

  Podcast emptyPodcast() {
    return Podcast("Not_Found",
        name: "Not_Found",
        description: "Not_Found",
        duration_ms: 0,
        show_name: "Not_Found",
        show_uri: "Not_Found",
        image_url: "Not_Found",
        comments: 0,
        commentsImg: [],
        release_date: "",
        watching: 0);
  }
}
