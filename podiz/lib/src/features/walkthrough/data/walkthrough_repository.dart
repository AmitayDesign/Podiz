import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firebase_walkthrough_repository.dart';

final walkthroughRepositoryProvider = Provider<WalkthroughRepository>(
  (ref) {
    final repository = FirebaseWalkthroughRepository(
      firestore: ref.watch(firestoreProvider),
    );
    return repository;
  },
);

abstract class WalkthroughRepository {
  Future<bool> isFirstTime(String userId);
  Future<void> complete(String userId);
}
