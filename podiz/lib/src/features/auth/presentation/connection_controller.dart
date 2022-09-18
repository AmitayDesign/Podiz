import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';
import 'package:podiz/src/utils/open_url.dart';
import 'package:uni_links/uni_links.dart';

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
  }) : super(authRepository.currentUser == null
            ? const AsyncValue.data(null)
            : const AsyncValue.loading()) {
    if (state.isLoading) signIn();
  }

  StreamSubscription? sub;
  Completer<String?>? loginCompleter;

  Future<void> signIn() async {
    final response = await openSignInUrl();
    print(response);
    if (response == null) return;
    try {
      final data = Uri.parse(response).queryParameters;
      final error = data['error'];
      if (error != null) throw Exception('Error: $error');
      final code = data['code']!;
      final userId = await authRepository.signIn(code);
      pushNotificationsRepository.requestPermission(userId);
    } catch (err, stack) {
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }

  Future<String?> openSignInUrl() async {
    loginCompleter?.complete();
    loginCompleter = Completer();
    await openUrl(spotifyApi.authenticationUrl);
    print("hello");
    state = const AsyncValue.data(null);
    sub?.cancel();
    sub = linkStream.listen((link) {
      print(link);
      if (link != null && link.startsWith(spotifyApi.redirectUrl)) {
        state = const AsyncValue.loading();
        loginCompleter!.complete(link);
      }
    }, onError: (err) => print(err.toString()));
    return await loginCompleter!.future.whenComplete(() => sub?.cancel());
  }

  @override
  void dispose() {
    loginCompleter?.complete();
    sub?.cancel();
    super.dispose();
  }
}
