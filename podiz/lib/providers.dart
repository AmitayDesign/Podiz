import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/notifications/NotificationManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';

import 'objects/show.dart';
import 'profile/userManager.dart';

//* USER

final userProvider = FutureProvider.family.autoDispose<UserPodiz, String>(
  (ref, id) => ref.watch(userManagerProvider).getUserFromUid(id),
);

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

//* SHOW

final showFutureProvider = FutureProvider.family.autoDispose<Show, String>(
  (ref, showId) async {
    final show = await ref.watch(showManagerProvider).fetchShow(showId);
    ref.keepAlive();
    return show;
  },
);
