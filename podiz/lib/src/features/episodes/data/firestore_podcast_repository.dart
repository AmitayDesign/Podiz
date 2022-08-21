import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/utils/firestore_refs.dart';
import 'package:podiz/src/utils/uri_from_id.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class FirestorePodcastRepository extends PodcastRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final SpotifyApi spotifyApi;

  FirestorePodcastRepository({
    required this.firestore,
    required this.functions,
    required this.spotifyApi,
  });

  @override
  Stream<Podcast> watchPodcast(String podcastId) {
    return firestore.showsCollection.doc(podcastId).snapshots().skipWhile(
      (doc) {
        if (!doc.exists) fetchSpotifyShow(podcastId);
        return !doc.exists;
      },
    ).map((doc) => Podcast.fromFirestore(doc));
  }

  @override
  Future<Podcast> fetchPodcast(String podcastId) async {
    final doc = await firestore.showsCollection.doc(podcastId).get();
    if (doc.exists) return Podcast.fromFirestore(doc);
    return fetchSpotifyShow(podcastId).then(fetchPodcast);
  }

  Future<String> fetchSpotifyShow(String showId) async {
    final accessToken = await spotifyApi.getAccessToken();
    final result = await functions
        .httpsCallable('fetchSpotifyShow')
        .call({'accessToken': accessToken, 'showId': showId});

    final success = result.data;
    if (!success) throw Exception('Failed to get show data');

    return showId;
  }

  @override
  Future<void> refetchPodcast(String podcastId) => fetchSpotifyShow(podcastId);

  @override
  Future<void> refetchFavoritePodcasts(String userId) async {
    final accessToken = await spotifyApi.getAccessToken();
    final result = await functions
        .httpsCallable('fetchSpotifyUserFavorites')
        .call({'accessToken': accessToken, 'userId': userId});

    final success = result.data;
    if (!success) throw Exception('Failed to refresh favorites');
  }

  @override
  Query<Podcast> podcastsFirestoreQuery(String filter) =>
      FirebaseFirestore.instance.showsCollection
          .where('searchArray', arrayContains: filter.toLowerCase())
          .withConverter(
            fromFirestore: (show, _) => Podcast.fromFirestore(show),
            toFirestore: (show, _) => {},
          );

  @override
  Future<void> follow(String userId, String podcastId) async {
    final batch = firestore.batch();
    batch.update(firestore.showsCollection.doc(podcastId), {
      'followers': FieldValue.arrayUnion([userId])
    });
    batch.update(firestore.usersCollection.doc(userId), {
      'favPodcasts': FieldValue.arrayUnion([podcastId])
    });
    await batch.commit();
    SpotifySdk.addToLibrary(spotifyUri: uriFromId(podcastId));
  }

  @override
  Future<void> unfollow(String userId, String podcastId) async {
    final batch = firestore.batch();
    batch.update(firestore.showsCollection.doc(podcastId), {
      'followers': FieldValue.arrayRemove([userId])
    });
    batch.update(firestore.usersCollection.doc(userId), {
      'favPodcasts': FieldValue.arrayRemove([podcastId])
    });
    await batch.commit();
    SpotifySdk.removeFromLibrary(spotifyUri: uriFromId(podcastId));
  }

  // List<String> getFavoritePodcasts() {
  //   return favShow;
  // }

  // Future<List<SearchResult>> searchShow(String text) async {
  //   QuerySnapshot<Map<String, dynamic>> docs = await firestore
  //       .showsCollection
  //       .where('name', isGreaterThanOrEqualTo: text)
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
