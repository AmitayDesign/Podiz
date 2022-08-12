import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/widgets/stream_notifier.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/notifications/NotificationManager.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/PlayerManager.dart';

import 'objects/show.dart';
import 'profile/userManager.dart';

// INSTANCES

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final authProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final storageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);
final functionsProvider = Provider<FirebaseFunctions>(
  (ref) => FirebaseFunctions.instance,
);
final connectivityProvider = StreamProvider<ConnectivityResult>(
  (ref) => Connectivity().onConnectivityChanged,
);

//* AUTH

final userLoadingProvider = FutureProvider.autoDispose<void>(
  (ref) => ref.watch(currentUserStreamProvider.future),
);

final currentUserStreamProvider = StreamProvider.autoDispose<UserPodiz?>(
  (ref) => ref.watch(authManagerProvider).userChanges,
);

final currentUserProvider =
    StateNotifierProvider.autoDispose<StreamNotifier<UserPodiz>, UserPodiz>(
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

final userProvider = FutureProvider.family<UserPodiz, String>(
  (ref, id) => ref.watch(userManagerProvider).getUserFromUid(id),
);

// NOTIFICATION

final notificationsStreamProvider =
    StreamProvider<Map<String, List<NotificationPodiz>>>(
        (ref) => ref.watch(notificationManagerProvider).notifications);

//* SHOW

final showFutureProvider = FutureProvider.family.autoDispose<Show, String>(
  (ref, showId) async {
    final show = await ref.watch(showManagerProvider).fetchShow(showId);
    ref.keepAlive();
    return show;
  },
);

//* PODCAST

final lastListenedPodcastStreamProvider = StreamProvider.autoDispose<Podcast?>(
  (ref) {
    final podcastManager = ref.watch(podcastManagerProvider);
    return ref.watch(currentUserStreamProvider.stream).asyncMap((user) {
      if (user == null) return null;
      return podcastManager.fetchPodcast(user.lastListened);
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

// PLAYER

final playerStreamProvider = StreamProvider<Player>(
  (ref) => ref.watch(playerManagerProvider).player,
);

final playerProvider = Provider<Player>(
  (ref) => ref.watch(playerStreamProvider).value!,
);

final stateProvider = StreamProvider<PlayerState>(
  (ref) => ref.watch(playerProvider).state,
);

final playerpodcastFutureProvider = StreamProvider.autoDispose<Podcast>(
  (ref) => ref.watch(playerProvider).podcast,
);

final commentsStreamProvider = StreamProvider.autoDispose<List<Comment>>(
  (ref) => ref.watch(playerManagerProvider).comments,
);
