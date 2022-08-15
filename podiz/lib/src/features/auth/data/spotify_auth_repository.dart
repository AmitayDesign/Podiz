import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/in_memory_store.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class SpotifyAuthRepository implements AuthRepository {
  final SpotifyApi spotifyApi;
  final FirebaseFunctions functions;
  final FirebaseFirestore firestore;
  final StreamingSharedPreferences preferences;

  final userKey = 'userId';
  final authState = InMemoryStore<UserPodiz?>();

  SpotifyAuthRepository({
    required this.spotifyApi,
    required this.functions,
    required this.firestore,
    required this.preferences,
  }) {
    listenToAuthStateChanges();
    listenToConnectionChanges();
  }

  late StreamSubscription sub;
  void listenToAuthStateChanges() {
    sub = preferences
        .getString(userKey, defaultValue: '')
        .asyncExpand((uid) async* {
      print('userId: $uid');
      if (uid.isEmpty) {
        yield null;
      } else {
        final doc = await firestore.collection('users').doc(uid).get();
        yield doc.exists ? UserPodiz.fromFirestore(doc) : null;
      }
    }).listen((user) => authState.value = user);
  }

  late StreamSubscription connectionSub;
  void listenToConnectionChanges() {
    connectionSub =
        SpotifySdk.subscribeConnectionStatus().listen((status) async {
      if (!status.connected) await preferences.remove(userKey);
    });
  }

  void dispose() {
    connectionSub.cancel();
    sub.cancel();
    authState.close();
  }

  @override
  Stream<UserPodiz?> authStateChanges() => authState.stream;

  @override
  UserPodiz? get currentUser => authState.value;

  @override
  Future<void> signOut() async {
    late bool success;
    try {
      success = await SpotifySdk.disconnect();
    } catch (e) {
      throw Exception('Sign out error: $e');
    }
    if (!success) throw Exception('Sign out failed');
  }

  @override
  Future<void> signIn() async {
    late final bool success;
    late final String userId;
    try {
      final accessToken = await spotifyApi.getAccessToken();
      success = await SpotifySdk.connectToSpotifyRemote(
        clientId: spotifyApi.clientId,
        redirectUrl: spotifyApi.redirectUrl,
        accessToken: accessToken,
      );
      userId = await setUserData(accessToken);
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
    if (!success) throw Exception('Error connecting to Spotify');
    await preferences.setString(userKey, userId);
  }

  Future<String> setUserData(String accessToken) async {
    final uri = Uri.parse('https://api.spotify.com/v1/me');
    var response = await spotifyApi.client.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });
    if (response.statusCode != 200) throw Exception('Failed to get user data');
    // decode response
    final parsedJson = jsonDecode(response.body) as Map<String, dynamic>;
    final userId = parsedJson['uri'] as String;
    final name = parsedJson['display_name'] as String;
    final email = parsedJson['email'] as String;
    final imageUrl = parsedJson['images'].first['url'] as String;
    // build search array
    //! I think you can use greaterThenOrEquals in the query instead
    var prev = '';
    final searchArray = [];
    for (final letter in name.split('')) {
      prev += letter;
      final word = prev.toLowerCase();
      searchArray.add(word);
    }
    // save user in firestore
    await firestore.collection('users').doc(userId).set(
      {
        'name': name,
        'email': email,
        'image_url': imageUrl,
        'searchArray': searchArray,
      },
      SetOptions(merge: true),
    );
    return userId;
  }
}


  //! called on sign in
  // Future<List<Podcast>> getCastList(UserPodiz user) async {
  //   List<Podcast> result = [];
  //   int number = user.favPodcastIds.length;
  //   int count = 0;
  //   if (number == 0) return [];
  //   if (number >= 6) {
  //     for (int i = number - 1; i >= 0; i--) {
  //       final show = await showManager.fetchShow(user.favPodcastIds[i]);
  //       final podcast = await podcastManager.getRandomEpisode(show.podcasts);
  //       if (podcast != null) result.add(podcast);
  //       count++;
  //       if (count == 6) {
  //         break;
  //       }
  //     }
  //   } else {
  //     for (int i = 0; i < number; i++) {
  //       final show = await showManager.fetchShow(user.favPodcastIds[i]);
  //       final podcast = await podcastManager.getRandomEpisode(show.podcasts);
  //       if (podcast != null) result.add(podcast);
  //       count++;
  //       if (i == number - 1) {
  //         i = 0;
  //       }
  //       if (count == 6) {
  //         break;
  //       }
  //     }
  //   }
  //   return result;
  //   //* refact
  //   // final podcasts = [];
  //   // final number = user.favPodcastIds.length.clamp(0, 6);
  //   // final lastFavPodcasts = user.favPodcastIds.reversed.take(number);
  //   // for (final podcastId in lastFavPodcasts) {
  //   //   final show = await showManager.fetchShow(podcastId);
  //   //   final podcast = await podcastManager.getRandomEpisode(show.podcasts);
  //   //   if (podcast != null) result.add(podcast);
  //   // }
  //   // return podcasts;
  // }

  