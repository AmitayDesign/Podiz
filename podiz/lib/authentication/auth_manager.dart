import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/instances.dart';

final authManagerProvider = Provider<AuthManager>(
  (ref) {
    final manager = AuthManager(ref.read);
    return manager;
  },
);

class AuthManager {
  final Reader _read;

  ShowManager get showManager => _read(showManagerProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  AuthManager(this._read);

  Stream<UserPodiz?> get userChanges =>
      _read(authRepositoryProvider).authStateChanges();
  UserPodiz? get currentUser => _read(authRepositoryProvider).currentUser;

  ///public

  // //TODO confirm if this is well done
  // Future<void> updateUser(
  //   BuildContext context, {
  //   required UserPodiz user,
  // }) async {
  //   try {
  //     await firebaseAuth.currentUser!.updateDisplayName(user.name);
  //     await firestore
  //         .collection('users')
  //         .doc(firebaseAuth.currentUser!.id)
  //         .update(user.toJson());
  //   } catch (_) {
  //     throw Failure.unexpected(context);
  //   }
  // }

  // Future<void> requestUserData(Map<String, String> request, context) async {
  //   //TODO review (had a loading before)
  //   await firestore.collection("clientInfo").doc(currentUser!.id).set(request);
  //   Navigator.pop(context);
  // } //GDPR conserns

  Future<void> updateLastListened(String episodeUid) async {
    await firestore
        .collection("users")
        .doc(currentUser!.id)
        .update({"lastListened": episodeUid});
  }

  Future<void> followPeople(String uid) async {
    final userUid = currentUser!.id;
    final batch = firestore.batch();
    batch.update(firestore.collection("users").doc(uid), {
      "followers": FieldValue.arrayUnion([userUid])
    });
    batch.update(firestore.collection("users").doc(userUid), {
      "following": FieldValue.arrayUnion([uid])
    });
    await batch.commit();
  }

  Future<void> unfollowPeople(String uid) async {
    final userUid = currentUser!.id;
    final batch = firestore.batch();
    batch.update(firestore.collection("users").doc(uid), {
      "followers": FieldValue.arrayRemove([userUid])
    });

    batch.update(firestore.collection("users").doc(userUid), {
      "following": FieldValue.arrayRemove([uid])
    });
    await batch.commit();
  }

  Future<void> followShow(String uid) async {
    final userUid = currentUser!.id;
    final batch = firestore.batch();
    batch.update(firestore.collection("podcasters").doc(uid), {
      "followers": FieldValue.arrayUnion([userUid])
    });
    batch.update(firestore.collection("users").doc(userUid), {
      "favPodcasts": FieldValue.arrayUnion([uid]),
      "following": FieldValue.arrayUnion([uid])
    });
    await batch.commit();
  }

  Future<void> unfollowShow(String uid) async {
    final userUid = currentUser!.id;
    final batch = firestore.batch();
    batch.update(firestore.collection("podcasters").doc(uid), {
      "followers": FieldValue.arrayRemove([userUid])
    });
    batch.update(firestore.collection("users").doc(userUid), {
      "favPodcasts": FieldValue.arrayRemove([uid]),
      "following": FieldValue.arrayRemove([uid])
    });
    await batch.commit();
  }

  bool isFollowing(String showUid) {
    return currentUser!.favPodcastIds.contains(showUid);
  }
}
