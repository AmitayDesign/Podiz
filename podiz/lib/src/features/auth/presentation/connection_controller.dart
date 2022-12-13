import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
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
  final SpotifyAPI spotifyApi;

  String? lastUsedUrl;

  ConnectionController({
    required this.authRepository,
    required this.pushNotificationsRepository,
    required this.spotifyApi,
  }) : super(authRepository.currentUser == null
            ? const AsyncValue.data(null)
            : const AsyncValue.loading()) {
    if (state.isLoading) signIn();
  }

  StreamSubscription? sub;
  Completer<String?>? loginCompleter;

  int signInTries = 0;
  Future<void> signIn() async {
    signInTries++;
    try {
      // open external spotify authentication window
      final response = await openSignInUrl();
      if (response == null) return;
      // get the authentication code from the response
      final data = Uri.parse(response).queryParameters;
      final error = data['error'];
      if (error != null) throw Exception('Error: $error');
      final code = data['code']!;
      // sign in with spotify
      final userId = await authRepository.signInWithSpotify(code);
      await pushNotificationsRepository.requestPermission(userId);
      state = const AsyncValue.data(null);
    } catch (err, stack) {
      signInTries < 3
          ? Future.delayed(const Duration(milliseconds: 200), signIn)
          : state = AsyncValue.error(err, stackTrace: stack);
    }
  }

  Future<String?> openSignInUrl() {
    state = const AsyncValue.loading();
    return FlutterWebAuth2.authenticate(
      url: Uri.parse(spotifyApi.authUrl).toString(),
      callbackUrlScheme: 'podiz',
    );
  }

  @override
  void dispose() {
    loginCompleter?.complete();
    sub?.cancel();
    super.dispose();
  }
}
