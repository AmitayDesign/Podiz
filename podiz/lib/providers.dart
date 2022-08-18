import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/notifications/NotificationManager.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';

import 'profile/userManager.dart';
import 'src/features/episodes/domain/podcast.dart';

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

final showFutureProvider = FutureProvider.family.autoDispose<Podcast, String>(
  (ref, showId) async {
    final show =
        await ref.watch(podcastRepositoryProvider).fetchPodcast(showId);
    ref.keepAlive();
    return show;
  },
);
