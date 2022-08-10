import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/failures/failure.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/main.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final authManagerProvider = Provider<AuthManager>(
  (ref) => AuthManager(ref.read),
);

class AuthManager {
  final Reader _read;

  PodcastManager get podcastManager => _read(podcastManagerProvider);
  ShowManager get showManager => _read(showManagerProvider);
  PlayerManager get playerManager => _read(playerManagerProvider);
  FirebaseAuth get firebaseAuth => _read(authProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  List<Podcast> myCast = [];

  final _userCompleter = Completer();
  Future<void> get firstUserLoad => _userCompleter.future;

  UserPodiz? currentUser;
  final _userStream = BehaviorSubject<UserPodiz?>();
  Stream<UserPodiz?> get user => _userStream.stream;

  AuthManager(this._read) {
    _init();
  }

  /// this can only be called once
  Future<void> _init() async {
    final loggedInUser = preferences.getString('userId');
    if (loggedInUser != null) {
      await fetchUserInfo(loggedInUser);
    } else {
      _saveUser(null);
    }
  }

  Future<void> fetchUserInfo(String userId) async {
    setUpUserStream(userId);
    await podcastManager.getDevices(userId);
    await podcastManager.fetchUserPlayer(userId);
  }

  void setUpUserStream(String userId) {
    print(userId);
    firestore.collection("users").doc(userId).snapshots().listen((doc) async {
      final data = doc.data();
      if (data == null) return;
      final user = UserPodiz.fromFirestore(doc);
      _saveUser(user);
    });
  }

  void _saveUser(UserPodiz? user) {
    user == null
        ? preferences.remove('userId')
        : preferences.setString('userId', user.uid);
    currentUser = user;
    _userStream.add(user);
    if (!_userCompleter.isCompleted) _userCompleter.complete();
  }

  Future<List<Podcast>> getCastList() async {
    List<Podcast> result = [];
    int number = currentUser!.favPodcasts.length;
    int count = 0;
    if (number >= 6) {
      for (int i = number - 1; i >= 0; i--) {
        Podcaster show =
            await showManager.getShowFromFirebase(currentUser!.favPodcasts[i]);
        String podcastUid = showManager.getRandomEpisode(show.podcasts);
        result.add(await podcastManager.getPodcastFromFirebase(podcastUid));
        count++;
        if (count == 6) {
          break;
        }
      }
    } else {
      while (count != 6) {
        for (int i = 0; i < number; i++) {
          Podcaster show = await showManager
              .getShowFromFirebase(currentUser!.favPodcasts[i]);
          String podcastUid = showManager.getRandomEpisode(show.podcasts);
          result.add(await podcastManager.getPodcastFromFirebase(podcastUid));
          count++;
          if (i == number - 1) {
            i = 0;
          }
        }
      }
    }
    return result;
  }

  void _emptyManagers() {
    podcastManager.resetManager();
    showManager.resetManager();
    // appManager.selectedRestaurantEvent.add(null);
  }

  ///public

  //TODO confirm if this is well done
  Future<void> updateUser(
    BuildContext context, {
    required UserPodiz user,
  }) async {
    try {
      await firebaseAuth.currentUser!.updateDisplayName(user.name);
      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update(user.toJson());
    } catch (_) {
      throw Failure.unexpected(context);
    }
  }

  void signOut(BuildContext context) async {
    _emptyManagers();
    _saveUser(null);
  }

  Future<void> requestUserData(Map<String, String> request, context) async {
    //TODO review (had a loading before)
    await firestore.collection("clientInfo").doc(currentUser!.uid).set(request);
    Navigator.pop(context);
  } //GDPR conserns

  Future<void> updateLastListened(String episodeUid) async {
    await firestore
        .collection("users")
        .doc(currentUser!.uid)
        .update({"lastListened": episodeUid});
  }

  doComment(String comment, String episodeUid, int time) async {
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

  doReply(Comment comment, String reply) async {
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

  incrementPodcastCounter(String episodeUid) {
    firestore.collection("podcasts").doc(episodeUid).update({
      "commentsImg": FieldValue.arrayUnion([currentUser!.image_url]),
      "comments": FieldValue.increment(1)
    });
  }

  followPeople(String uid) {
    String userUid = currentUser!.uid;
    firestore.collection("users").doc(uid).update({
      "followers": FieldValue.arrayUnion([userUid])
    });
    firestore.collection("users").doc(userUid).update({
      "following": FieldValue.arrayUnion([uid])
    });
  }

  unfollowPeople(String uid) {
    String userUid = currentUser!.uid;
    firestore.collection("users").doc(uid).update({
      "followers": FieldValue.arrayRemove([userUid])
    });

    firestore.collection("users").doc(userUid).update({
      "following": FieldValue.arrayRemove([uid])
    });
  }

  followShow(String uid) {
    String userUid = currentUser!.uid;
    firestore.collection("podcasters").doc(uid).update({
      "followers": FieldValue.arrayUnion([userUid])
    });
    firestore.collection("users").doc(userUid).update({
      "favPodcasts": FieldValue.arrayUnion([uid]),
      "following": FieldValue.arrayUnion([uid])
    });
  }

  unfollowShow(String uid) {
    String userUid = currentUser!.uid;
    firestore.collection("podcasters").doc(uid).update({
      "followers": FieldValue.arrayRemove([userUid])
    });
    firestore.collection("users").doc(userUid).update({
      "favPodcasts": FieldValue.arrayRemove([uid]),
      "following": FieldValue.arrayRemove([uid])
    });
  }

  bool isFollowing(String showUid) {
    return currentUser!.favPodcasts.contains(showUid);
  }
}
