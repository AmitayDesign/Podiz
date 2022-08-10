import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/onboarding/SpotifyManager.dart';

final spotifyControllerProvider =
    StateNotifierProvider<SpotifyController, AsyncValue>((ref) {
  final manager = ref.watch(spotifyManagerProvider);
  final authManager = ref.watch(authManagerProvider);
  return SpotifyController(manager: manager, authManager: authManager);
});

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
      final token = await manager.fetchAuthorizationToken(code);
      await authManager.fetchUserInfo(token);
    });
  }
}
