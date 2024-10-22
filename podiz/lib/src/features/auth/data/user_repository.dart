import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firestore_user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => FirestoreUserRepository(
      firestore: ref.watch(firestoreProvider),
      mixPanelRepository: ref.watch(mixPanelRepository)),
);

abstract class UserRepository {
  Future<UserPodiz> fetchUser(String userId);
  Stream<UserPodiz> watchUser(String userId);
  Query<UserPodiz> usersFirestoreQuery(String filter);
  Future<void> follow(String userId, String userToFollowId);
  Future<void> unfollow(String userId, String userToFollowId);
}

final userFutureProvider = FutureProvider.family<UserPodiz, String>(
  (ref, userId) => ref.watch(userRepositoryProvider).fetchUser(userId),
);

final userStreamProvider = StreamProvider.family<UserPodiz, String>(
  (ref, userId) => ref.watch(userRepositoryProvider).watchUser(userId),
);
