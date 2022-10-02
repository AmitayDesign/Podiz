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

  final forceSignInFormKey = 'forceSignInForm';

  final clientId = '5deee54ca37b4fc59abaa2869233bb3d';
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

  bool get forceSignInForm =>
      preferences.getBool(forceSignInFormKey, defaultValue: false).getValue();

  //debug: add &show_dialog=true to disallow auto login
  String get authenticationUrl =>
      '$baseUrl?client_id=$clientId&response_type=$responseType&redirect_uri=$redirectUrl&scope=$scope&state=$state&show_dialog=$forceSignInForm';

  http.Client client = http.Client();

  late String userId;
  String? accessToken;
  DateTime? timeout;
  VoidCallback? onDisconnect;

  bool get tokenExpired => timeout?.isBefore(DateTime.now()) ?? true;

  Future<String> getAccessToken() async {
    print("### GET ACCESS TOKEN!!!!");
    if (!tokenExpired && accessToken != null) return accessToken!;
    print("accrsssss token");
    final response = await functions
        .httpsCallable('getAccessTokenWithRefreshToken')
        .call({'userId': userId});

    final result = response.data['result'];
    if (result == 'unauthorized') {
      onDisconnect?.call();
      throw Exception('session timed out');
    }
    if (result == 'error') throw Exception('access token error');
    accessToken = result;

    await connectToSdk();

    return accessToken!;
  }

  Future<bool> connectToSdk() {
    print("### CONNNECTING!!!!!!!");
    if (Platform.isIOS) {
      return SpotifySdk.connectToSpotifyRemote(
          clientId: clientId,
          redirectUrl: redirectUrl,
          scope: scope,
          spotifyUri: ""
          // accessToken: accessToken,
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
