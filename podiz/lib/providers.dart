import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity/connectivity.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/PlayerManager.dart';

// Instance Providers

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

// Object Providers

final userStreamProvider = StreamProvider<UserPodiz?>(
  (ref) => ref.watch(authManagerProvider).user,
);

final userProvider = Provider<UserPodiz>(
  (ref) => ref.watch(userStreamProvider).value!,
);

final podcastsStreamProvider = StreamProvider<Map<String, Podcast>>(
  (ref) => ref.watch(podcastManagerProvider).podcasts,
);

final podcastsProvider = Provider<Map<String, Podcast>>(
  (ref) => ref.watch(podcastsStreamProvider).value!,
);

final showStreamProvider = StreamProvider<List<Podcaster>>(
  (ref) => ref.watch(showManagerProvider).podcasts,
);

final showProvider = Provider<List<Podcaster>>(
  (ref) => ref.watch(showStreamProvider).value!,
);

final playerStreamProvider = StreamProvider<Player>(
  (ref) => ref.watch(playerManagerProvider).player,
);

final playerProvider = Provider<Player>(
  (ref) => ref.watch(playerStreamProvider).value!,
);
