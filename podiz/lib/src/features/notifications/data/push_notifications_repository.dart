import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firebase_push_notifications_repository.dart';

final pushNotificationsRepositoryProvider =
    Provider<PushNotificationsRepository>(
  (ref) {
    final repository = FirebasePushNotificationsRepository(
      plugin: ref.watch(localNotificationsProvider),
      messaging: ref.watch(messagingProvider),
      firestore: ref.watch(firestoreProvider),
    );
    ref.onDispose(repository.dispose);
    return repository;
  },
);

abstract class PushNotificationsRepository {
  Future<void> init();
  Future<void> requestPermission(String userId);
  Future<void> revokePermission(String userId);
  Future<void> handleNotifications();
  Stream<String> selectedNotificationChanges();
}

final selectedNotificationStreamProvider = StreamProvider<String>(
  (ref) => ref
      .watch(pushNotificationsRepositoryProvider)
      .selectedNotificationChanges(),
);
