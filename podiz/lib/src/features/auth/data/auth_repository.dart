import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/instances.dart';
import 'package:podiz/src/utils/stream_notifier.dart';

import 'spotify_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    final repository = SpotifyAuthRepository(
      spotifyApi: ref.watch(spotifyApiProvider),
      functions: ref.watch(functionsProvider),
      firestore: ref.watch(firestoreProvider),
      preferences: ref.watch(preferencesProvider),
    );
    ref.onDispose(repository.dispose);
    return repository;
  },
);

abstract class AuthRepository {
  Stream<UserPodiz?> authStateChanges();
  UserPodiz? get currentUser;
  //
  Stream<bool> connectionChanges();
  bool get isConnected;
  //
  Future<String> signIn(String code);
  Future<void> signOut();
  Future<void> updateUser(UserPodiz user);
  //
  Future<void> requestData();
  Future<void> wipeData();
}

//* Providers

/// awaits for the first connection state
final firstUserFutureProvider = FutureProvider<void>(
  (ref) => ref.read(authStateChangesProvider.future),
);

final authStateChangesProvider = StreamProvider<UserPodiz?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

final connectionChangesProvider = StreamProvider<bool>(
  (ref) => ref.watch(authRepositoryProvider).connectionChanges(),
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
