import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';

class FirestorePodcastRepository extends PodcastRepository {
  final FirebaseFirestore firestore;
  final SpotifyApi spotifyApi;
  // final PodcastRepository podcastRepository;

  FirestorePodcastRepository({
    required this.firestore,
    required this.spotifyApi,
  });

  @override
  Stream<Podcast> watchPodcast(String podcastId) {
    return firestore
        .collection('podcasters')
        .doc(podcastId)
        .snapshots()
        .map((doc) => Podcast.fromFirestore(doc));
  }

  @override
  Future<Podcast> fetchPodcast(String podcastId) async {
    final doc = await firestore.collection('podcasters').doc(podcastId).get();
    // if (doc.exists)
    return Podcast.fromFirestore(doc);
    // return fetchPodcastFromSpotify(podcastId);
  }

  // TODO fetch podcast from spotify
  // Future<Podcast> fetchPodcastFromSpotify(String podcastId) async {
  //   final accessToken = spotifyApi.getAccessToken();
  //   // final uri = Uri.https('api.spotify.com/v1/episodes', '/$podcastId');
  //   final uri = Uri.parse('https://api.spotify.com/v1/episodes/$podcastId');
  //   final response = await spotifyApi.client.get(uri, headers: {
  //     'Accept': 'application/json',
  //     'Authorization': 'Bearer $accessToken',
  //     'Content-Type': 'application/json',
  //   });
  //   if (response.statusCode != 200) {
  //     //TODO always throwing error
  //     throw Exception('Failed to get podcast data');
  //   }

  //   final parsedJson = jsonDecode(response.body) as Map<String, dynamic>;
  //   debugPrint(parsedJson.toString()); //TODO  get show id and name
  //   final podcast = Podcast.fromSpotify(parsedJson);
  //   //TODO save on firestore
  //   // await firestore
  //   //     .collection('podcasters')
  //   //     .doc(podcastId)
  //   //     .set(podcast.toFirestore());
  //   //TODO load more episodes aswell
  //   return podcast;
  // }

  @override
  Query<Podcast> podcastsFirestoreQuery(String filter) =>
      FirebaseFirestore.instance
          .collection("podcasters")
          .where("searchArray", arrayContains: filter.toLowerCase())
          .withConverter(
            fromFirestore: (show, _) => Podcast.fromFirestore(show),
            toFirestore: (show, _) => {},
          );

  @override
  Future<void> follow(String userId, String podcastId) async {
    final batch = firestore.batch();
    batch.update(firestore.collection("podcasters").doc(podcastId), {
      "followers": FieldValue.arrayUnion([userId])
    });
    batch.update(firestore.collection("users").doc(userId), {
      "favPodcasts": FieldValue.arrayUnion([podcastId]),
      "following": FieldValue.arrayUnion([podcastId])
    });
    await batch.commit();
  }

  @override
  Future<void> unfollow(String userId, String podcastId) async {
    final batch = firestore.batch();
    batch.update(firestore.collection("podcasters").doc(podcastId), {
      "followers": FieldValue.arrayRemove([userId])
    });
    batch.update(firestore.collection("users").doc(userId), {
      "favPodcasts": FieldValue.arrayRemove([podcastId]),
      "following": FieldValue.arrayRemove([podcastId])
    });
    await batch.commit();
  }

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
