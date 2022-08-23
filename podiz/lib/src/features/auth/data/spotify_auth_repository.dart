import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/firestore_refs.dart';
import 'package:podiz/src/utils/in_memory_store.dart';
import 'package:podiz/src/utils/null_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class SpotifyAuthRepository with AuthState implements AuthRepository {
  @override
  final FirebaseFirestore firestore;
  @override
  final StreamingSharedPreferences preferences;

  final SpotifyApi spotifyApi;
  final FirebaseFunctions functions;

  SpotifyAuthRepository({
    required this.spotifyApi,
    required this.functions,
    required this.firestore,
    required this.preferences,
  }) {
    listenToAuthStateChanges();
    listenToConnectionChanges();
  }

  late StreamSubscription connectionSub;
  void listenToConnectionChanges() {
    connectionSub =
        SpotifySdk.subscribeConnectionStatus().listen((status) async {
      if (!status.connected && preferences.getStringOrNull(userKey) != null) {
        signIn();
      }
    });
  }

  @override
  void dispose() {
    connectionSub.cancel();
    super.dispose();
  }

  @override
  Stream<UserPodiz?> authStateChanges() => authState.stream;

  @override
  UserPodiz? get currentUser => authState.value;

  @override
  Future<void> signIn() async {
    late final bool success;
    try {
      final accessToken = await spotifyApi.getAccessToken();
      success = await SpotifySdk.connectToSpotifyRemote(
        //! ios autoplay workarroud
        // this uri does not exist and so the player wont start automatically
        spotifyUri: 'null',
        clientId: spotifyApi.clientId,
        redirectUrl: spotifyApi.redirectUrl,
        accessToken: accessToken,
      );
      await fetchUser(accessToken);
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
    if (!success) throw Exception('Error connecting to Spotify');
  }

  Future<void> fetchUser(String accessToken) async {
    // https://github.com/firebase/functions-samples/blob/main/spotify-auth/functions/index.js
    final result = await functions
        .httpsCallable('fetchSpotifyUser')
        .call({'accessToken': accessToken});

    final userId = result.data;
    if (userId == null) throw Exception('Failed to get user data');

    await preferences.setString(userKey, userId);
    await authState.first;
  }

  @override
  Future<void> signOut() async {
    late bool success;
    try {
      success = await preferences.remove(userKey);
      if (success) await SpotifySdk.disconnect();
    } catch (e) {
      throw Exception('Sign out error: $e');
    }
    if (!success) throw Exception('Sign out failed');
  }

  @override
  Future<void> updateUser(UserPodiz user) {
    return firestore.usersCollection
        .doc(user.id)
        .update(user.toJson())
        .catchError((e) => throw Exception('Error updating user'));
  }
}

abstract class AuthState {
  StreamingSharedPreferences get preferences;
  FirebaseFirestore get firestore;

  final userKey = 'userId';
  final authState = InMemoryStore<UserPodiz?>();

  StreamSubscription? authStateSub;
  StreamSubscription? userSub;
  void listenToAuthStateChanges() {
    authStateSub = preferences
        .watchString(userKey)
        .transform(
          StreamTransformer<String?, UserPodiz?>.fromHandlers(
            handleData: (userId, sink) {
              userSub?.cancel();
              if (userId == null) sink.add(null);
              userSub = firestore.usersCollection
                  .doc(userId!)
                  .snapshots()
                  .listen((doc) {
                final user = UserPodiz.fromFirestore(doc);
                sink.add(user);
              });
            },
            handleDone: (sink) => userSub?.cancel(),
            handleError: (e, _, sink) {
              userSub?.cancel();
              sink.add(null);
            },
          ),
        )
        .listen((user) => authState.value = user);
  }

  void dispose() {
    userSub?.cancel();
    authStateSub?.cancel();
    authState.close();
  }
}
