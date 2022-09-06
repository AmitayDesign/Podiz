import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';

final connectionControllerProvider =
    StateNotifierProvider.autoDispose<ConnectionController, AsyncValue>(
  (ref) => ConnectionController(
    spotifyApi: ref.watch(spotifyApiProvider),
    repository: ref.watch(authRepositoryProvider),
  ),
);

class ConnectionController extends StateNotifier<AsyncValue> {
  final AuthRepository repository;
  final SpotifyApi spotifyApi;

  String? lastUsedUrl;

  ConnectionController({
    required this.repository,
    required this.spotifyApi,
  }) : super(const AsyncValue.loading());

  void init() => state = const AsyncValue.data(null);

  String get connectionUrl => spotifyApi.authenticationUrl;

  bool isValidUrl(String url) => url.contains(spotifyApi.redirectUrl);

  Future<void> retrySignIn() {
    assert(lastUsedUrl != null);
    return signIn(lastUsedUrl!);
  }

  Future<void> signIn(String url) async {
    lastUsedUrl = url;
    state = const AsyncValue.loading();
    try {
      final error = Uri.parse(url).queryParameters['error'];
      if (error != null) throw Exception('Error: $error');
      final code = Uri.parse(url).queryParameters['code']!;
      await repository.signIn(code);
    } catch (err, stack) {
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }
}
