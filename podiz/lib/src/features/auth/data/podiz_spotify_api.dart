import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/animation.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'spotify_api.dart';

class PodizSpotifyAPI implements SpotifyAPI {
  final FirebaseFunctions functions;
  final StreamingSharedPreferences prefs;

  PodizSpotifyAPI({required this.functions, required this.prefs});

  final forceSignInFormKey = 'forceSignInForm';

  Future<void> forceSignInForm({bool force = true}) =>
      prefs.setBool(forceSignInFormKey, force);

  bool get forceSignInFormValue =>
      prefs.getBool(forceSignInFormKey, defaultValue: false).getValue();

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

  @override
  String get authUrl =>
      '$baseUrl?client_id=$clientId&response_type=$responseType&redirect_uri=$redirectUrl&scope=$scope&state=$state&show_dialog=$forceSignInFormValue';

  @override
  bool stopIOSPlayer = false; //!
  late String userId;
  DateTime? timeout;
  VoidCallback? onDisconnect;

  @override
  Future<String> fetchAuthTokenFromCode(
    String code, {
    VoidCallback? onDisconnect,
  }) async {
    // get access token
    final now = DateTime.now();
    final result = await functions
        .httpsCallable('getAccessTokenWithCode2')
        .call({'code': code});
    // handle result
    if (result.data == '0') throw Exception('Failed to get user data');
    accessToken = result.data['access_token'];
    final timeoutInSeconds = result.data['timeout'];
    final authToken = result.data['authToken'];
    userId = result.data['userId'];
    //
    timeout = now.add(Duration(seconds: timeoutInSeconds));
    stopIOSPlayer = true;
    onDisconnect = onDisconnect;
    // connect to sdk
    final success = await connectToSdk();
    if (!success) throw Exception('Error connecting to Spotify');
    return authToken;
  }

  String? accessToken;
  bool get tokenExpired => timeout?.isBefore(DateTime.now()) ?? true;

  @override
  Future<String> fetchAccessToken() async {
    // return current access token if valid
    if (!tokenExpired && accessToken != null) return accessToken!;

    // else, get new access token
    final response = await functions
        .httpsCallable('getAccessTokenWithRefreshToken')
        .call({'userId': userId});
    // handle responde
    final result = response.data['result'];
    if (result == 'unauthorized') {
      onDisconnect?.call();
      throw Exception('session timed out');
    }
    if (result == 'error') throw Exception('access token error');
    // save and return new access token and connect to sdk
    accessToken = result;
    await connectToSdk();
    await forceSignInForm(force: false);
    return accessToken!;
  }

  @override
  Future<bool> connectToSdk() {
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

  @override
  Future<void> disconnect() async {
    await forceSignInForm();
    await SpotifySdk.disconnect();
  }
}
