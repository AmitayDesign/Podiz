import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/utils/date_from_timestamp.dart';
import 'package:podiz/src/utils/firestore_refs.dart';

import 'episode_repository.dart';

class FirestoreEpisodeRepository extends EpisodeRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final SpotifyAPI spotifyApi;
  final DateTime date;

  FirestoreEpisodeRepository(
      {required this.firestore,
      required this.functions,
      required this.spotifyApi,
      required this.date});

  @override
  Stream<Episode> watchEpisode(String episodeId) =>
      firestore.episodesCollection.doc(episodeId).snapshots().skipWhile(
        (doc) {
          if (!doc.exists) fetchSpotifyEpisode(episodeId);
          return !doc.exists;
        },
      ).map((doc) => Episode.fromFirestore(doc));

  @override
  Future<Episode> fetchEpisode(String episodeId) async {
    final doc = await firestore.episodesCollection.doc(episodeId).get();
    if (doc.exists) return Episode.fromFirestore(doc);
    return fetchSpotifyEpisode(episodeId).then(fetchEpisode);
  }

  Future<String> fetchSpotifyEpisode(String episodeId) async {
    final accessToken = await spotifyApi.fetchAccessToken();
    final result = await functions
        .httpsCallable('fetchSpotifyEpisode')
        .call({'accessToken': accessToken, 'episodeId': episodeId});
    final success = result.data;
    if (!success) throw Exception('Failed to get episode data');

    return episodeId;
  }

  @override
  Future<Episode?> fetchLastShowEpisode(String showId) async {
    final snapshot = await firestore.episodesCollection
        .where('showId', isEqualTo: showId)
        .orderBy('releaseDate', descending: true)
        .limit(1)
        .get();
    if (snapshot.size == 1) return Episode.fromFirestore(snapshot.docs.single);
    return null;
  }

  @override
  Query<Episode> showEpisodesFirestoreQuery(String showId) =>
      firestore.episodesCollection
          .where('showId', isEqualTo: showId)
          .orderBy('releaseDate', descending: true)
          .withConverter(
            fromFirestore: (doc, _) => Episode.fromFirestore(doc),
            toFirestore: (episode, _) => {},
          );

  @override
  Query<Episode> episodesFirestoreQuery(String filter) =>
      firestore.episodesCollection
          .where('searchArray', arrayContains: filter.toLowerCase())
          .withConverter(
            fromFirestore: (doc, _) => Episode.fromFirestore(doc),
            toFirestore: (episode, _) => {},
          );

  @override
  Query<Episode> hotliveFirestoreQuery() => firestore.episodesCollection
      // .where('commentsCount', isNotEqualTo: -1)
      .where('releaseDate', isGreaterThan: stringFromDate(date))
      .orderBy('releaseDate', descending: true)
      .orderBy('commentsCount', descending: true)
      .withConverter(
        fromFirestore: (doc, _) => Episode.fromFirestore(doc),
        toFirestore: (episode, _) => {},
      );

  @override
  Query<Episode> hotliveFirestoreQueryRemainig() => firestore.episodesCollection
      .where('releaseDate', isLessThan: stringFromDate(date))
      // .orderBy('commentsCount', descending: true)
      .orderBy('releaseDate', descending: true)
      .withConverter(
        fromFirestore: (doc, _) => Episode.fromFirestore(doc),
        toFirestore: (episode, _) => {},
      );

  @override
  Stream<List<Episode>> trendingEpisodesOnDate(DateTime date) =>
      firestore.episodesCollection
          .where('releaseDate', isEqualTo: stringFromDate(date))
          .where('commentsCount', isGreaterThan: 0)
          .orderBy('commentsCount', descending: true)
          .limit(7)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Episode.fromFirestore(doc)).toList());
}
