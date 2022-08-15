import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/instances.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

final authManagerProvider = Provider<AuthManager>(
  (ref) {
    final manager = AuthManager(ref.read);
    return manager;
  },
);

class AuthManager {
  final Reader _read;

  ShowManager get showManager => _read(showManagerProvider);
  PodcastManager get podcastManager => _read(podcastManagerProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);
  StreamingSharedPreferences get preferences => _read(preferencesProvider);

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

  Future<void> doComment(String comment, String episodeUid, int time) async {
    DocRef doc = firestore
        .collection("podcasts")
        .doc(episodeUid)
        .collection("comments")
        .doc();
    String date = DateTime.now().toIso8601String();
    firestore
        .collection("podcasts")
        .doc(episodeUid)
        .collection("comments")
        .doc(doc.id)
        .set({
      "id": doc.id,
      "timestamp": date,
      "userUid": currentUser!.id,
      "episodeUid": episodeUid,
      "comment": comment,
      "time": time,
      "lvl": 1,
      "parents": [],
    });

    firestore.collection("users").doc(currentUser!.id).update({
      "comments": FieldValue.arrayUnion([
        {
          "id": doc.id,
          "comment": comment,
          "time": time,
          "userUid": currentUser!.id,
          "episodeUid": episodeUid,
          "timestamp": date,
          "lvl": 1,
          "parents": [],
        }
      ]),
    });
    incrementPodcastCounter(episodeUid);
  }

  Future<void> doReply(Comment comment, String reply) async {
    DocRef doc = firestore
        .collection("podcasts")
        .doc(comment.episodeUid)
        .collection("comments")
        .doc();
    String date = DateTime.now().toIso8601String();
    List<String> parents = comment.parents;
    print(comment.id);
    parents.add(comment.id);
    print(parents);
    firestore
        .collection("podcasts")
        .doc(comment.episodeUid)
        .collection("comments")
        .doc(doc.id)
        .set({
      "id": doc.id,
      "timestamp": date,
      "userUid": currentUser!.id,
      "episodeUid": comment.episodeUid,
      "comment": reply,
      "time": comment.time,
      "lvl": comment.lvl + 1,
      "parents": parents,
    });

    firestore.collection("users").doc(currentUser!.id).update({
      "comments": FieldValue.arrayUnion([
        {
          "id": doc.id,
          "comment": reply,
          "time": comment.time,
          "userUid": currentUser!.id,
          "episodeUid": comment.episodeUid,
          "timestamp": date,
          "lvl": comment.lvl + 1,
          "parents": parents,
        }
      ]),
    });
    incrementPodcastCounter(comment.episodeUid);
    if (currentUser!.id == comment.userUid) {
      return;
    }
    firestore
        .collection("users")
        .doc(comment.userUid)
        .collection("notifications")
        .doc()
        .set({
      "id": doc.id,
      "timestamp": date,
      "userUid": currentUser!.id,
      "episodeUid": comment.episodeUid,
      "comment": reply,
      "time": comment.time,
      "lvl": comment.lvl + 1,
      "parents": parents,
    });
  }

  Future<void> incrementPodcastCounter(String episodeUid) =>
      firestore.collection("podcasts").doc(episodeUid).update({
        "commentsImg": FieldValue.arrayUnion([currentUser!.imageUrl]),
        "comments": FieldValue.increment(1)
      });

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
