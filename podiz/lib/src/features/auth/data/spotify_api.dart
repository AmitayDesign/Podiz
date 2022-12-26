import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/utils/instances.dart';

import 'podiz_spotify_api.dart';

final spotifyApiProvider = Provider<SpotifyAPI>(
  (ref) => PodizSpotifyAPI(
    functions: ref.watch(functionsProvider),
    prefs: ref.watch(preferencesProvider),
  ),
);

abstract class SpotifyAPI {
  bool get stopIOSPlayer;
  set stopIOSPlayer(bool value);
  String get authUrl;
  Future<String> fetchAuthTokenFromCode(
    String code, {
    VoidCallback? onDisconnect,
  });
  Future<String> fetchAccessToken();
  Future<bool> connectToSdk();
  Future<void> disconnect();
}
