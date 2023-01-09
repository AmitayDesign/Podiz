import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
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
    'user-follow-read', //
    'user-read-private', //
    // 'user-read-email',
    'user-read-currently-playing', //
    'user-read-playback-position', //
    'user-library-read', //
    // 'user-library-modify',
    'user-modify-playback-state' //
  ].join(' ');

  @override
  String get authUrl =>
      '$baseUrl?client_id=$clientId&response_type=$responseType&redirect_uri=$redirectUrl&scope=$scope&state=$state&show_dialog=$forceSignInFormValue';

  String? userId;
  DateTime? timeout;
  String? accessToken;
  bool get tokenExpired => timeout?.isBefore(DateTime.now()) ?? true;

  @override
  Future<String> fetchAuthTokenFromCode(String code) async {
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
    timeout = now.add(Duration(seconds: timeoutInSeconds));
    await forceSignInForm(force: false);
    return authToken;
  }

  @override
  Future<String> fetchAccessToken() async {
    // if valid, returns current access token
    if (!tokenExpired && accessToken != null) return accessToken!;

    // else, fetch new access token
    final response = await functions
        .httpsCallable('getAccessTokenWithRefreshToken')
        .call({'userId': userId});
    // handle response
    final result = await response.data['result'];
    if (result == 'unauthorized') {
      throw Exception('session timed out');
    } else if (result == 'error') {
      throw Exception('access token error');
    }
    // save and return new access token
    accessToken = result;
    // await connectToSdk();
    return accessToken!;
  }

  @override
  bool shouldPausePlayer = false;

  @override
  Future<bool> connectToSdk() async {
    if (Platform.isIOS) {
      final accessToken = await fetchAccessToken();
      final response = await functions
          .httpsCallable('fetchSpotifyIsPlaying')
          .call({'accessToken': accessToken});
      final isPlaying = response.data;
      if (isPlaying == false) shouldPausePlayer = true;
    }
    return SpotifySdk.connectToSpotifyRemote(
      clientId: clientId,
      redirectUrl: redirectUrl,
      playerName: 'Podiz',
    );
  }

  @override
  Future<void> disconnect() async {
    await forceSignInForm();
    await SpotifySdk.disconnect();
    userId = null;
    accessToken = null;
    timeout = null;
  }

  @override
  void setUserId(String userId) {
    this.userId = userId;
  }
}
