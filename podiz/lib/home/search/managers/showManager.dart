import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/show.dart';
import 'package:podiz/providers.dart';

final showManagerProvider = Provider.autoDispose<ShowManager>(
  (ref) => ShowManager(
    firestore: ref.watch(firestoreProvider),
  ),
);

class ShowManager {
  final FirebaseFirestore firestore;
  ShowManager({required this.firestore});

  Future<Show> fetchShow(String showId) async {
    final doc = await firestore.collection("podcasters").doc(showId).get();
    final show = Show.fromFirestore(doc);
    return show;
  }

  Query<Show> showsFirestoreQuery(String filter) => FirebaseFirestore.instance
      .collection("podcasters")
      .where("searchArray", arrayContains: filter.toLowerCase())
      .withConverter(
        fromFirestore: (show, _) => Show.fromFirestore(show),
        toFirestore: (show, _) => {},
      );

  // List<String> getFavoritePodcasts() {
  //   return favShow;
  // }

  // Future<List<SearchResult>> searchShow(String text) async {
  //   QuerySnapshot<Map<String, dynamic>> docs = await firestore
  //       .collection("podcasters")
  //       .where("name", isGreaterThanOrEqualTo: text)
  //       .get();
  //   List<SearchResult> result = [];
  //   for (int i = 0; i < docs.docs.length; i++) {
  //     Podcaster show = Podcaster.fromFirestore(docs.docs[i]);
  //     result.add(podcasterToSearchResult(show));
  //   }

  //   return result;
  // }

  // SearchResult podcasterToSearchResult(Podcaster show) {
  //   return SearchResult(
  //       uid: show.uid!,
  //       name: show.name,
  //       description: show.description,
  //       image_url: show.image_url,
  //       publisher: show.publisher,
  //       total_episodes: show.total_episodes,
  //       podcasts: show.podcasts,
  //       followers: show.followers);
  // }

  // List<String>? getEpisodes(String showId) {
  //   if (showBloc.containsKey(showId)) {
  //     return showBloc[showId]!.podcasts;
  //   }
  //   return null;
  // }

  // String? getShowImageUrl(String showId) {
  //   if (showBloc.containsKey(showId)) {
  //     return showBloc[showId]!.image_url;
  //   }
  //   return null;
  // }
}
