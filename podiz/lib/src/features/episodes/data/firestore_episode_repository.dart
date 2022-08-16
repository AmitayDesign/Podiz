import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';

class FirestoreEpisodeRepository extends EpisodeRepository {
  final FirebaseFirestore firestore;
  final SpotifyApi spotifyApi;
  // final PodcastRepository podcastRepository;

  FirestoreEpisodeRepository({
    required this.firestore,
    required this.spotifyApi,
  });

  // TODO do this fetch in the widget
  // player should only have episodeId field
  @override
  Future<Episode> fetchEpisode(String episodeId) async {
    final doc = await firestore
        .collection('podcasts')
        .doc(episodeId)
        .get(); //! fix collection name
    if (!doc.exists) {
      final accessToken = spotifyApi.getAccessToken();
      final uri = Uri.parse('https://api.spotify.com/v1/episodes/$episodeId');
      final response = await spotifyApi.client.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });
      if (response.statusCode != 200) {
        //TODO always throwing error
        throw Exception('Failed to get podcast data');
      }

      final parsedJson = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint(parsedJson.toString()); //TODO  get show id and name
      final episode = Episode.fromSpotify(parsedJson);
      debugPrint(episode.toFirestore().toString());
      // await firestore
      //     .collection('podcasts')
      //     .doc(episodeId)
      //     .set(episode.toFirestore());
      // await showRepository.fetchShow(showId); //TODO load show aswell
      return episode;
    }
    return Episode.fromFirestore(doc);
  }

  @override
  Query<Episode> episodesFirestoreQuery(String filter) =>
      FirebaseFirestore.instance
          .collection("podcasts")
          .where("searchArray", arrayContains: filter.toLowerCase())
          .withConverter(
            fromFirestore: (doc, _) => Episode.fromFirestore(doc),
            toFirestore: (episode, _) => {},
          );

  @override
  Query<Episode> hotliveFirestoreQuery() => FirebaseFirestore.instance
      .collection("podcasts")
      .orderBy("release_date", descending: true)
      .withConverter(
        fromFirestore: (doc, _) => Episode.fromFirestore(doc),
        toFirestore: (episode, _) => {},
      );
}
