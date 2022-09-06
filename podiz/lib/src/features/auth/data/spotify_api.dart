import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:podiz/src/utils/instances.dart';
import 'package:podiz/src/utils/null_preferences.dart';
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

    final userId = preferences.getStringOrNull('userId'); //! hardcoded
    final response = await functions
        .httpsCallable('getAccessTokenWithRefreshToken')
        .call({'userId': userId});

    final result = response.data['result'];
    // if (result == 'unauthorized') //TODO sign in screen;
    if (result == 'error') throw Exception('access token error');
    print(result);
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
