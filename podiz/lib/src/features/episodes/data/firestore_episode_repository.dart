import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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
    final doc = await firestore
        .collection('podcasts')
        .doc(episodeId)
        .get(); //! fix collection name
    if (!doc.exists) {
      final accessToken = spotifyApi.getAccessToken();
      final uri = Uri.parse('https://api.spotify.com/v1/episodes/$episodeId');
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to get podcast data');
      }

      final parsedJson = jsonDecode(response.body) as Map<String, dynamic>;
      print(parsedJson); //TODO  get show id and name
      final episode = Episode.fromSpotify(parsedJson);
      // await showRepository.fetchShow(showId); //TODO load show aswell
      return episode;
    }
    return Episode.fromFirestore(doc);
  }
}
