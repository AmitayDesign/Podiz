import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/onboarding/SpotifyManager.dart';

//TODO autodispose?
final spotifyControllerProvider =
    StateNotifierProvider<SpotifyController, AsyncValue>(
  (ref) => SpotifyController(
    manager: ref.watch(spotifyManagerProvider),
    authManager: ref.watch(authManagerProvider),
  ),
);

class SpotifyController extends StateNotifier<AsyncValue> {
  final SpotifyManager manager;
  final AuthManager authManager;

  SpotifyController({
    required this.manager,
    required this.authManager,
  }) : super(const AsyncValue.data(null));

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final code = await manager.fetchAuthorizationCode();
      print(code);
      final token = await manager.fetchAuthorizationToken(code);
      print(token);
      await authManager.signIn(token);
    });
  }
}
