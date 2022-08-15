import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/in_memory_store.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class SpotifyAuthRepository implements AuthRepository {
  final FirebaseFunctions functions;
  final FirebaseFirestore firestore;
  final StreamingSharedPreferences preferences;

  final userKey = 'userId';
  final authState = InMemoryStore<UserPodiz?>();

  final clientId = '9a8daaf39e784f1c90770da4a252087f';
  final redirectUrl = 'podiz:/';

  SpotifyAuthRepository({
    required this.functions,
    required this.firestore,
    required this.preferences,
  }) {
    listenToAuthStateChanges();
  }

  late StreamSubscription sub;
  void listenToAuthStateChanges() {
    final userIdStream = preferences.getString(userKey, defaultValue: '');
    final userStream = userIdStream.asyncExpand((userId) {
      if (userId.isEmpty) return null;
      final userDocStream =
          firestore.collection("users").doc(userId).snapshots();
      return userDocStream.map((doc) {
        if (!doc.exists) return null;
        return UserPodiz.fromFirestore(doc);
      });
    });
    sub = userStream.listen((user) => authState.value = user);
  }

  void dispose() {
    sub.cancel();
    authState.close();
  }

  @override
  Stream<UserPodiz?> authStateChanges() {
    print('authStateChanges');
    final connectionStatusStream = SpotifySdk.subscribeConnectionStatus();
    return connectionStatusStream.asyncExpand((connectionStatus) async* {
      if (connectionStatus.connected) {
        print('connected');
        yield* authState.stream;
      } else {
        print('not connected');
        yield null;
      }
    });
  }

  @override
  UserPodiz? get currentUser => authState.value;

  @override
  Future<void> signOut() async {
    late bool success;
    try {
      success = await SpotifySdk.disconnect();
      if (success) success = await preferences.remove(userKey);
    } catch (e) {
      throw Exception('Sign out error: $e');
    }
    if (!success) throw Exception('Sign out failed');
  }

  @override
  Future<void> signIn() async {
    //TODO use SpotifySdk to get the access token
    // final accessToken = await SpotifySdk.getAccessToken(
    //   clientId: clientId,
    //   redirectUrl: redirectUrl,
    //   scope: scope,
    // );
    late final bool success;
    try {
      final code = await fetchCode();
      final userId = await fetchUserId(code);
      final accessToken = await fetchAccessToken(userId);
      await connectToSpotifySdk(accessToken);
      success = await preferences.setString(userKey, userId);
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
    if (!success) throw Exception('Sign in failed');
  }

  Future<String> fetchCode() async {
    const authorizationUrl = 'https://accounts.spotify.com/authorize';
    const responseType = 'code';
    const scope =
        'user-follow-read user-read-private user-read-email user-modify-playback-state user-read-playback-state user-read-currently-playing user-library-read user-read-playback-position';
    const state = '34fFs29kd09';

    final url =
        '$authorizationUrl?client_id=$clientId&response_type=$responseType&redirect_uri=$redirectUrl&scope=$scope&state=$state';

    final response = await FlutterWebAuth.authenticate(
      url: url,
      callbackUrlScheme: 'podiz',
    );

    final error = Uri.parse(response).queryParameters['error'];
    if (error != null) throw Exception(error);
    final code = Uri.parse(response).queryParameters['code']!;
    return code;
  }

  Future<String> fetchUserId(String code) async {
    HttpsCallableResult result = await functions
        .httpsCallable('getAccessTokenWithCode')
        .call({'code': code});

    final userId = result.data;
    if (userId != '0') return userId;
    throw Exception(
      'Something went wrong, check your internet connection or try again later!',
    );
  }

  Future<String> fetchAccessToken(String userId) async {
    final tokenDocRef = firestore.collection('spotifyAuth').doc(userId);
    final tokenDoc = await tokenDocRef.get();
    final accessToken = tokenDoc.get('access_token');
    return accessToken;
  }

  Future<void> connectToSpotifySdk(String accessToken) async {
    final success = await SpotifySdk.connectToSpotifyRemote(
      clientId: clientId,
      redirectUrl: redirectUrl,
      accessToken: accessToken,
    );
    if (!success) throw Exception('Error connecting to Spotify');
  }
}
