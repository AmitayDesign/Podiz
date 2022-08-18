import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/notifications/NotificationManager.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';

//* NOTIFICATION

//TODO why not list
final notificationsStreamProvider =
    StreamProvider.autoDispose<Map<String, List<NotificationPodiz>>>(
  (ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    if (user == null) return Stream.value({});
    return ref.watch(notificationManagerProvider).watchNotifications(user.id);
  },
);
