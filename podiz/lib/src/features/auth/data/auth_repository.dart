import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/instances.dart';
import 'package:podiz/src/utils/stream_notifier.dart';

import 'firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    final repository = FirebaseAuthRepository(
      spotifyApi: ref.watch(spotifyApiProvider),
      firestore: ref.watch(firestoreProvider),
      auth: ref.watch(authProvider),
    );
    ref.onDispose(repository.dispose);
    return repository;
  },
);

abstract class AuthRepository {
  Stream<UserPodiz?> authStateChanges();
  UserPodiz? get currentUser;
  //
  Future<String> signInWithSpotify(String code);
  Future<void> sendEmailVerification();
  Future<void> updateUser(UserPodiz user);
  Future<void> reloadUser();
  Future<void> signOut();
}

//* Providers

/// awaits for the first connection state
final firstUserFutureProvider = FutureProvider<void>(
  (ref) => ref.read(authStateChangesProvider.future),
);

final authStateChangesProvider = StreamProvider<UserPodiz?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

final currentUserProvider =
    StateNotifierProvider<StreamNotifier<UserPodiz>, UserPodiz>(
  (ref) {
    final repository = ref.watch(authRepositoryProvider);
    return StreamNotifier(
      initial: repository.currentUser!,
      stream: repository
          .authStateChanges()
          .where((user) => user != null)
          .cast<UserPodiz>(),
    );
  },
);
