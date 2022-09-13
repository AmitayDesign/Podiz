import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/utils/instances.dart';

import 'showcase_view_repository.dart';

final showcaseRepositoryProvider = Provider<ShowcaseRepository>(
  (ref) {
    final repository = ShowcaseViewRepository(
      preferences: ref.watch(preferencesProvider),
    );
    // ref.onDispose(repository.dispose);
    return repository;
  },
);

abstract class ShowcaseRepository {
  bool get isFirstTime;
  Future<void> disable();
}
