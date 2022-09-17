import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    try {
      // final response = await FlutterWebAuth2.authenticate(
      //   url: spotifyApi.authenticationUrl,
      //   callbackUrlScheme: 'podiz',
      // );
      final url = spotifyApi.authenticationUrl;
      final loginCompleter = Completer();
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        throw Exception('Could not open a browser for authentication');
      }
      linkStream.listen((link) {
        print('## LINK STREAM: $link');
        if (link != null && link.startsWith(spotifyApi.redirectUrl)) {
          print('## LINK PASSED!!');
          loginCompleter.complete(link);
        }
      }, onError: (e) => print('## $e'));
      final response = await loginCompleter.future;
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
}
