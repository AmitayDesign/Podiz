import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity/connectivity.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/user/User.dart';

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




