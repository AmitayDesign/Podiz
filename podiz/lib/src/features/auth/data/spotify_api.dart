import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/instances.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

final spotifyApiProvider = Provider<SpotifyApi>(
  (ref) => SpotifyApi(ref.read),
);

class SpotifyApi {
  final Reader _read;
  FirebaseFunctions get functions => _read(functionsProvider);
  UserPodiz get user => _read(currentUserProvider);

  SpotifyApi(this._read);

  final clientId = '9a8daaf39e784f1c90770da4a252087f';
  final redirectUrl = 'podiz:/';
  final responseType = "code";
  final state = "34fFs29kd09";
  final baseUrl = "https://accounts.spotify.com/authorize";
  final scope = [
    'user-follow-read',
    'user-read-private',
    'user-read-email',
    'user-read-playback-position',
    'user-library-read',
    'user-library-modify',
  ].join(' ');

  String get authenticationUrl =>
      "$baseUrl?client_id=$clientId&response_type=$responseType&redirect_uri=$redirectUrl&scope=$scope&state=$state";

  http.Client client = http.Client();

  String? accessToken;
  DateTime? timeout;

  bool get tokenExpired => timeout?.isAfter(DateTime.now()) ?? true;

  Future<String> getAccessToken() async {
    if (!tokenExpired && accessToken != null) return accessToken!;

    final response = await functions
        .httpsCallable('getAccessTokenWithRefreshToken')
        .call({'userId': user.id});

    final result = response.data['result'];
    // if (result == 'unauthorized') //TODO sign in screen;
    if (result == 'error') throw Exception('access token error');

    accessToken = result;
    await connectToSdk(accessToken!);
    return accessToken!;
  }

  Future<bool> connectToSdk(String accessToken) =>
      SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUrl,
        accessToken: accessToken,
      );
}
