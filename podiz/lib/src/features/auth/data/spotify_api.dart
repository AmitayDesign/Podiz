import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

final spotifyApiProvider = Provider<SpotifyApi>((ref) => SpotifyApi());

class SpotifyApi {
  final clientId = '9a8daaf39e784f1c90770da4a252087f';
  final redirectUrl = 'podiz:/';
  final scope = [
    'user-follow-read',
    'user-read-private',
    'user-read-email',
  ].join(' ');

  Future<String> getAccessToken() => SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUrl,
        scope: scope,
      );
}
