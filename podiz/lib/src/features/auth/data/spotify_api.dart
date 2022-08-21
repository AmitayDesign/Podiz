import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/spotify_sdk.dart';

final spotifyApiProvider = Provider<SpotifyApi>((ref) => SpotifyApi());

class SpotifyApi {
  final clientId = '9a8daaf39e784f1c90770da4a252087f';
  final redirectUrl = 'podiz:/';
  final scope = [
    'user-follow-read',
    'user-read-private',
    'user-read-email',
    'user-read-playback-position',
    'user-library-read'
  ].join(' ');

  http.Client client = http.Client();

  Future<String> getAccessToken() => SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUrl,
        scope: scope,
      );
}
