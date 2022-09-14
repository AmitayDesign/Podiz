import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';

final connectionControllerProvider =
    StateNotifierProvider.autoDispose<ConnectionController, AsyncValue>(
  (ref) => ConnectionController(
    spotifyApi: ref.watch(spotifyApiProvider),
    authRepository: ref.watch(authRepositoryProvider),
    pushNotificationsRepository: ref.watch(pushNotificationsRepositoryProvider),
  ),
);

class ConnectionController extends StateNotifier<AsyncValue> {
  final AuthRepository authRepository;
  final PushNotificationsRepository pushNotificationsRepository;
  final SpotifyApi spotifyApi;

  String? lastUsedUrl;

  ConnectionController({
    required this.authRepository,
    required this.pushNotificationsRepository,
    required this.spotifyApi,
  }) : super(const AsyncValue.loading());

  void init() => state = const AsyncValue.data(null);

  String get connectionUrl => spotifyApi.authenticationUrl;

  bool isValidUrl(String url) {
    if (Uri.parse(url).queryParameters['code'] != null) {
      return true;
    }
    return false;
  }

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
      final userId = await authRepository.signIn(code);
      //pushNotificationsRepository.requestPermission(userId);
    } catch (err, stack) {
      state = AsyncValue.error(err, stackTrace: stack);
      print(err);
    }
  }
}
