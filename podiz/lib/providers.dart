import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/notifications/NotificationManager.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/stream_notifier.dart';

import 'objects/show.dart';
import 'profile/userManager.dart';

// INSTANCES

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final functionsProvider = Provider<FirebaseFunctions>(
  (ref) => FirebaseFunctions.instance,
);

//* AUTH

final userLoadingProvider = FutureProvider<void>(
  (ref) => ref.watch(currentUserStreamProvider.future),
);

final currentUserStreamProvider = StreamProvider<UserPodiz?>(
  (ref) => ref.watch(authManagerProvider).userChanges,
);

final currentUserProvider =
    StateNotifierProvider<StreamNotifier<UserPodiz>, UserPodiz>(
  (ref) {
    final manager = ref.watch(authManagerProvider);
    return StreamNotifier(
      initial: manager.currentUser!,
      stream:
          manager.userChanges.where((user) => user != null).cast<UserPodiz>(),
    );
  },
);

//* USER

final userProvider = FutureProvider.family.autoDispose<UserPodiz, String>(
  (ref, id) => ref.watch(userManagerProvider).getUserFromUid(id),
);

//* NOTIFICATION

//TODO why not list
final notificationsStreamProvider =
    StreamProvider.autoDispose<Map<String, List<NotificationPodiz>>>(
  (ref) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
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

//* PODCAST

final lastListenedPodcastStreamProvider = StreamProvider<Podcast?>(
  (ref) {
    final podcastManager = ref.watch(podcastManagerProvider);
    return ref.watch(currentUserStreamProvider.stream).asyncMap((user) {
      if (user == null) return null;
      return podcastManager.fetchPodcast(user.lastPodcastId);
    });
  },
);

final podcastFutureProvider =
    FutureProvider.family.autoDispose<Podcast, String>(
  (ref, id) async {
    final podcast = await ref.watch(podcastManagerProvider).fetchPodcast(id);
    ref.keepAlive();
    return podcast;
  },
);

//* PLAYER

final playerStreamProvider = StreamProvider<Player?>(
  (ref) => ref.watch(playerManagerProvider).playerStream,
);

final playerPositionStreamProvider = StreamProvider<Duration?>(
  (ref) {
    final player = ref.watch(playerStreamProvider).valueOrNull;
    if (player == null) return Stream.value(null);
    return player.positionChanges;
  },
);

// COMMENTS

final commentsStreamProvider = StreamProvider.autoDispose<List<Comment>>(
  (ref) => ref.watch(playerManagerProvider).comments,
);
