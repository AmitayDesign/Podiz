import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firebase_showcase_repository.dart';

final showcaseRepositoryProvider = Provider<ShowcaseRepository>(
  (ref) {
    final repository = FirebaseShowcaseRepository(
      firestore: ref.watch(firestoreProvider),
    );
    // ref.onDispose(repository.dispose);
    return repository;
  },
);

abstract class ShowcaseRepository {
  Future<bool> isFirstTime(String userId);
  Future<void> disable(String userId);
}
