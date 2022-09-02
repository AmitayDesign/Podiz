import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';

final onboardingControllerProvider =
    StateNotifierProvider.autoDispose<OnboardingController, AsyncValue>(
  (ref) => OnboardingController(
    repository: ref.watch(authRepositoryProvider),
  ),
);

class OnboardingController extends StateNotifier<AsyncValue> {
  final AuthRepository repository;

  OnboardingController({required this.repository})
      : super(const AsyncValue.data(null));

  Future<void> signIn(String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.signIn(code));
  }
}
