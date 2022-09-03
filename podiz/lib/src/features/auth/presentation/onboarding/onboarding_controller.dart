import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';

final onboardingControllerProvider =
    StateNotifierProvider.autoDispose<OnboardingController, AsyncValue>(
  (ref) => OnboardingController(
    spotifyApi: ref.watch(spotifyApiProvider),
    repository: ref.watch(authRepositoryProvider),
  ),
);

class OnboardingController extends StateNotifier<AsyncValue> {
  final AuthRepository repository;
  final SpotifyApi spotifyApi;

  OnboardingController({
    required this.repository,
    required this.spotifyApi,
  }) : super(const AsyncValue.data(null));

  Future<bool> signIn(String url) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final error = Uri.parse(url).queryParameters['error'];
      if (error != null) throw Exception('Error: $error');

      final code = Uri.parse(url).queryParameters['code']!;
      await repository.signIn(code);
    });

    if (state.hasError) return false;
    return true;
  }
}
