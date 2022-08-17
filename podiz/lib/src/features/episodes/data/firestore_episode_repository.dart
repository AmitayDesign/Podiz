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

  @override
  Future<Episode> fetchEpisode(String episodeId) async {
    final doc = await firestore.collection('podcasts').doc(episodeId).get();
    if (doc.exists) return Episode.fromFirestore(doc);
    return fetchEpisodeFromSpotify(episodeId);
  }

  Future<Episode> fetchEpisodeFromSpotify(String episodeId) async {
    final accessToken = spotifyApi.getAccessToken();
    // final uri = Uri.https('api.spotify.com/v1/episodes', '/$episodeId');
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
    //TODO save on firestore
    // await firestore
    //     .collection('podcasts')
    //     .doc(episodeId)
    //     .set(episode.toFirestore());
    ////TODO load show aswell
    // await showRepository.fetchShow(showId);
    return episode;
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
