import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/mutable_user_podiz.dart';

final onboardingControllerProvider =
    StateNotifierProvider.autoDispose<OnboardingController, AsyncValue>(
  (ref) => OnboardingController(
    authRepository: ref.watch(authRepositoryProvider),
  ),
);

class OnboardingController extends StateNotifier<AsyncValue> {
  final AuthRepository authRepository;

  OnboardingController({
    required this.authRepository,
  }) : super(const AsyncValue.data(null));

  Future<void> setEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = authRepository.currentUser!;
      final updatedUser = user.updateEmail(email);
      await authRepository.updateUser(updatedUser);
    });
  }
}
