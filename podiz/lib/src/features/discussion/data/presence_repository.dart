import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/data/database_presence_repository.dart';
import 'package:podiz/src/utils/instances.dart';

final presenceRepositoryProvider = Provider<PresenceRepository>(
  (ref) {
    final repository = DatabasePresenceRepository(
      database: ref.watch(databaseProvider),
      firestore: ref.watch(firestoreProvider),
    );
    ref.onDispose(repository.dispose);
    return repository;
  },
);

abstract class PresenceRepository {
  Future<void> updateLastListened(String userId, String episodeId);
  Future<void> configureUserPresence(String userId, String episodeId);
  Future<void> disconnect();
}
