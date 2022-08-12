import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/main.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final authManagerProvider = Provider.autoDispose<AuthManager>(
  (ref) {
    final manager = AuthManager(
      podcastManager: ref.watch(podcastManagerProvider),
      showManager: ref.watch(showManagerProvider),
      firebaseAuth: ref.watch(authProvider),
      firestore: ref.watch(firestoreProvider),
    );
    ref.onDispose(manager.dispose);
    return manager;
  },
);

class AuthManager {
  final PodcastManager podcastManager;
  final ShowManager showManager;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthManager({
    required this.podcastManager,
    required this.showManager,
    required this.firebaseAuth,
    required this.firestore,
  }) {
    final loggedInUser = preferences.getString('userId');
    if (loggedInUser != null) {
      signIn(loggedInUser);
    } else {
      _saveUser(null);
    }
  }


  Future<void> fetchUserInfo(String userId) async {
    _setUpUserStream(userId);
    // await podcastManager.getDevices(userId);
  }
  void dispose() {
    _userController.close();
  }

  final _userController = BehaviorSubject<UserPodiz?>();
  Stream<UserPodiz?> get userChanges => _userController.stream;
  UserPodiz? get currentUser => _userController.value;

  List<Podcast> myCast = [];

  Future<void> signIn(String userId) async {
    _setUpUserStream(userId);
    await podcastManager.getDevices(userId);
    // await podcastManager.fetchUserPlayer(userId);
  }

  void _setUpUserStream(String userId) =>
      firestore.collection("users").doc(userId).snapshots().listen((doc) async {
        final data = doc.data();
        final user = data == null ? null : UserPodiz.fromFirestore(doc);
        await _saveUser(user);
      });

  Future<void> _saveUser(UserPodiz? user) async {
    if (user == null) {
      preferences.remove('userId');
    } else {
      preferences.setString('userId', user.uid);
      myCast = await getCastList(user);
    }
    _userController.add(user);
  }

  Future<List<Podcast>> getCastList(UserPodiz user) async {
    List<Podcast> result = [];
    int number = user.favPodcasts.length;
    int count = 0;
    if (number == 0) return [];
    if (number >= 6) {
      for (int i = number - 1; i >= 0; i--) {
        final show = await showManager.fetchShow(user.favPodcasts[i]);
        final podcast = await podcastManager.getRandomEpisode(show.podcasts);
        if (podcast != null) result.add(podcast);
        count++;
        if (count == 6) {
          break;
        }
      }
    } else {
      while (count != 6) {
        for (int i = 0; i < number; i++) {
          final show = await showManager.fetchShow(user.favPodcasts[i]);
          final podcast = await podcastManager.getRandomEpisode(show.podcasts);
          if (podcast != null) result.add(podcast);
          count++;
          if (i == number - 1) {
            i = 0;
          }
        }
      }
    }
    return result;
    //* refact
    // final podcasts = [];
    // final number = user.favPodcasts.length.clamp(0, 6);
    // final lastFavPodcasts = user.favPodcasts.reversed.take(number);
    // for (final podcastId in lastFavPodcasts) {
    //   final show = await showManager.fetchShow(podcastId);
    //   final podcast = await podcastManager.getRandomEpisode(show.podcasts);
    //   if (podcast != null) result.add(podcast);
    // }
    // return podcasts;
  }

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
  //         .doc(firebaseAuth.currentUser!.uid)
  //         .update(user.toJson());
  //   } catch (_) {
  //     throw Failure.unexpected(context);
  //   }
  // }

  // Future<void> signOut(BuildContext context) async {
  //   await _saveUser(null);
  // }

  // Future<void> requestUserData(Map<String, String> request, context) async {
  //   //TODO review (had a loading before)
  //   await firestore.collection("clientInfo").doc(currentUser!.uid).set(request);
  //   Navigator.pop(context);
  // } //GDPR conserns

  Future<void> updateLastListened(String episodeUid) async {
    await firestore
        .collection("users")
        .doc(currentUser!.uid)
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
      "userUid": currentUser!.uid,
      "episodeUid": episodeUid,
      "comment": comment,
      "time": time,
      "lvl": 1,
      "parents": [],
    });

    firestore.collection("users").doc(currentUser!.uid).update({
      "comments": FieldValue.arrayUnion([
        {
          "id": doc.id,
          "comment": comment,
          "time": time,
          "userUid": currentUser!.uid,
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
      "userUid": currentUser!.uid,
      "episodeUid": comment.episodeUid,
      "comment": reply,
      "time": comment.time,
      "lvl": comment.lvl + 1,
      "parents": parents,
    });

    firestore.collection("users").doc(currentUser!.uid).update({
      "comments": FieldValue.arrayUnion([
        {
          "id": doc.id,
          "comment": reply,
          "time": comment.time,
          "userUid": currentUser!.uid,
          "episodeUid": comment.episodeUid,
          "timestamp": date,
          "lvl": comment.lvl + 1,
          "parents": parents,
        }
      ]),
    });
    incrementPodcastCounter(comment.episodeUid);
    if (currentUser!.uid == comment.userUid) {
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
      "userUid": currentUser!.uid,
      "episodeUid": comment.episodeUid,
      "comment": reply,
      "time": comment.time,
      "lvl": comment.lvl + 1,
      "parents": parents,
    });
  }

  Future<void> incrementPodcastCounter(String episodeUid) =>
      firestore.collection("podcasts").doc(episodeUid).update({
        "commentsImg": FieldValue.arrayUnion([currentUser!.image_url]),
        "comments": FieldValue.increment(1)
      });

  Future<void> followPeople(String uid) async {
    final userUid = currentUser!.uid;
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
    final userUid = currentUser!.uid;
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
    final userUid = currentUser!.uid;
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
    final userUid = currentUser!.uid;
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
    return currentUser!.favPodcasts.contains(showUid);
  }
}
