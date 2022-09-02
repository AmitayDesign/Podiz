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

class SpotifyAuthRepository
    with AuthState, ConnectionState
    implements AuthRepository {
  //
  @override
  final FirebaseFirestore firestore;
  @override
  final StreamingSharedPreferences preferences;

  @override
  final SpotifyApi spotifyApi;
  final FirebaseFunctions functions;

  @override
  final userKey = 'userId';

  SpotifyAuthRepository({
    required this.spotifyApi,
    required this.functions,
    required this.firestore,
    required this.preferences,
  }) {
    listenToAuthStateChanges();
    listenToConnectionChanges();
  }

  void dispose() {
    disposeAuthState();
    disposeConnectionState();
  }

  @override
  Stream<bool> connectionChanges() => connectionState.stream;

  @override
  Stream<UserPodiz?> authStateChanges() => authState.stream;

  @override
  UserPodiz? get currentUser => authState.value;

  @override
  Future<void> signIn(String code) async {
    late final bool success;
    try {
      final accessToken = await getAccessTokenWithCode(code);
      success = await spotifyApi.connectToSdk(accessToken);
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
    if (!success) throw Exception('Error connecting to Spotify');
    // wait for the user to be fetched before ending the login
    // so it doesnt display a wrong frame
    await authState.first;
  }

  Future<String> getAccessTokenWithCode(String code) async {
    //TODO connnect spotify to firebaseAuth
    //* https://github.com/firebase/functions-samples/blob/main/spotify-auth/functions/index.js

    final now = DateTime.now();
    final result = await functions
        .httpsCallable('getAccessTokenWithCode')
        .call({'code': code});

    if (result.data == '0') throw Exception('Failed to get user data');

    final accessToken = result.data['access_token'];
    final timeout = result.data['timeout']; // in seconds
    spotifyApi.accessToken = accessToken;
    spotifyApi.timeout = now.add(Duration(seconds: timeout));

    final userId = result.data['userId'];
    await preferences.setString(userKey, userId);

    return accessToken;
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

mixin AuthState {
  StreamingSharedPreferences get preferences;
  FirebaseFirestore get firestore;

  String get userKey;
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

  void disposeAuthState() {
    userSub?.cancel();
    authStateSub?.cancel();
    authState.close();
  }
}

mixin ConnectionState {
  SpotifyApi get spotifyApi;
  StreamingSharedPreferences get preferences;
  FirebaseFirestore get firestore;

  String get userKey;
  final connectionState = InMemoryStore<bool>();

  StreamSubscription? connectionSub;
  void listenToConnectionChanges() {
    connectionSub =
        SpotifySdk.subscribeConnectionStatus().listen((status) async {
      connectionState.value = status.connected;
      if (!status.connected && preferences.getStringOrNull(userKey) != null) {
        spotifyApi.getAccessToken();
      }
    });
  }

  void disposeConnectionState() {
    connectionSub?.cancel();
  }
}
