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

  final _podcastStream = BehaviorSubject<Map<String, Podcast>>();
  Stream<Map<String, Podcast>> get podcasts => _podcastStream.stream;

  PodcastManager(this._read) {
    print("Settings up podacast stream!");
    firestore.collection("podcasts").snapshots().listen((snapshot) async {
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
    podcastBloc.addAll({doc.id: podcast});
    // firestore.collection("podcasts").doc(doc.id).update({"commentsImg": [], "comments":0});
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

  SearchResult getPodcastById(String podcastId) {
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
          release_date: podcast.release_date);
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
        release_date: "");
  }

  List<Podcast> getMyCast(List<String> shows) {
    if (shows.length > 6) {
      shows.shuffle();
    }
    int count = 0;
    List<Podcast> result = [];
    for (int i = 0; i < shows.length || count == 6; i++) {
      List<String> episodesId = showManager.getEpisodes(shows[i]);
      Podcast episode = getRandomEpisode(episodesId);
      result.add(episode);
      count++;
    }

    return result;
  }

  Podcast getRandomEpisode(List<String> episodesId) {
    if (episodesId.isEmpty) {
      return emptyPodcast();
    }
    int index = Random().nextInt(episodesId.length);
    Podcast result = podcastBloc[episodesId[index]]!;
    return result;
  }

  List<Podcast> getHotLive() {
    List<Podcast> result = [];
    podcastBloc.forEach((key, value) => result.add(value));
    // result.sort((a, b) => b.release_date.compareTo(a.release_date));
    result.sublist(0, 20);
    return result;
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
        release_date: "");
  }
}
