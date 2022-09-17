import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:podiz/src/utils/instances.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

final spotifyApiProvider = Provider<SpotifyApi>(
  (ref) => SpotifyApi(
    functions: ref.watch(functionsProvider),
    preferences: ref.watch(preferencesProvider),
  ),
);

class SpotifyApi {
  final FirebaseFunctions functions;
  final StreamingSharedPreferences preferences;

  SpotifyApi({required this.functions, required this.preferences});

  final clientId = '9a8daaf39e784f1c90770da4a252087f';
  final redirectUrl = 'podiz:/connect';
  final responseType = 'code';
  final state = '34fFs29kd09';
  final baseUrl = 'https://accounts.spotify.com/authorize';
  final scope = [
    'app-remote-control',
    'user-follow-read',
    'user-read-private',
    'user-read-email',
    'user-read-playback-position',
    'user-library-read',
    'user-library-modify',
    'user-modify-playback-state'
  ].join(' ');
  final forceSignInForm = false;

  //debug: add &show_dialog=true to disallow auto login
  String get authenticationUrl =>
      '$baseUrl?client_id=$clientId&response_type=$responseType&redirect_uri=$redirectUrl&scope=$scope&state=$state&show_dialog=$forceSignInForm';

  http.Client client = http.Client();

  late String userId;
  String? accessToken;
  DateTime? timeout;
  VoidCallback? disconnect;

  bool get tokenExpired => timeout?.isBefore(DateTime.now()) ?? true;

  Future<String> getAccessToken() async {
    if (!tokenExpired && accessToken != null) return accessToken!;

    final response = await functions
        .httpsCallable('getAccessTokenWithRefreshToken')
        .call({'userId': userId});

    final result = response.data['result'];
    if (result == 'unauthorized') {
      disconnect?.call();
      throw Exception('session timed out');
    }
    if (result == 'error') throw Exception('access token error');
    accessToken = result;

    await connectToSdk();

    return accessToken!;
  }

  Future<bool> connectToSdk() {
    if (Platform.isIOS) {
      return SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUrl,
        scope: scope,
      );
    }

    return SpotifySdk.connectToSpotifyRemote(
      clientId: clientId,
      redirectUrl: redirectUrl,
      accessToken: accessToken,
      playerName: 'Podiz',
    );
  }
}
