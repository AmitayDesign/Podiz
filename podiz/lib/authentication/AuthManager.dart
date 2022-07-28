import 'dart:async';

import 'package:podiz/aspect/failures/failure.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/services/fileHandler.dart';

import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final authManagerProvider = Provider<AuthManager>(
  (ref) => AuthManager(ref.read),
);

class AuthManager {
  final Reader _read;

  PodcastManager get podcastManager => _read(podcastManagerProvider);
  ShowManager get showManager => _read(showManagerProvider);
  FirebaseAuth get firebaseAuth => _read(authProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  UserPodiz? userBloc;

  final _userCompleter = Completer();
  Future<void> get firstUserLoad => _userCompleter.future;

  final _userStream = BehaviorSubject<UserPodiz?>();
  Stream<UserPodiz?> get user => _userStream.stream;

  AuthManager(this._read) {
    _loadUserInfo();
  }

  _loadUserInfo() async {
    try {
      if (await FileHandler.fileExists("user.txt")) {
        final json = await FileHandler.readFromFile("user.txt");
        userBloc = UserPodiz.fromJson(json!);
        await fetchUserInfo(userBloc!.uid!);
      } else {
        userBloc = null;
        _userStream.add(userBloc);
      }
    } catch (e) {
      return "error";
    }
    if (!_userCompleter.isCompleted) _userCompleter.complete(); //TODO
  }

  fetchUserInfo(String userID) async {
    await setUpUserStream(userID);
    await podcastManager.getDevices(userID);
    // await podcastManager.setUpPodcastStream();
  }

  _emptyManagers() {
    podcastManager.resetManager();
    showManager.resetManager();
    // appManager.selectedRestaurantEvent.add(null);
  }

  saveUser() async {
    await FileHandler.writeToFile(userBloc, "user.txt");
    _userStream.add(userBloc);
  }

  deleteUserFile() async {
    userBloc = null;
    await FileHandler.deleteFile("user.txt");
    _userStream.add(userBloc);
  }

  setUpUserStream(String uid) async {
    final userReference = firestore.collection('users').doc(uid);
    Doc userData = await userReference.get();
    int totalTimeWaiting = 0;
    while (userData.data() == null && totalTimeWaiting < 2000) {
      await Future.delayed(Duration(milliseconds: 100));
      userData = await userReference.get();
      totalTimeWaiting += 100;
    }

    userBloc = UserPodiz.fromFirestore(userData);
    await saveUser();

    firestore.collection("users").doc(uid).snapshots().listen((snapshot) async {
      if (snapshot.data() != null) {
        userBloc = UserPodiz.fromJson(snapshot.data()!);
        userBloc!.uid = uid;
        await saveUser();
        print("done");
      } else {
        print("upsssss");
      }
    });
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

  Future<void> signOut(BuildContext context) async {
    await _emptyManagers();
    await deleteUserFile();
  }

  Future<void> requestUserData(Map<String, String> request, context) async {
    //TODO review (had a loading before)
    await firestore.collection("clientInfo").doc(userBloc!.uid).set(request);
    Navigator.pop(context);
  } //GDPR conserns

  Future<void> updateLastListened(String episodeUid) async {
    await firestore
        .collection("users")
        .doc(userBloc!.uid)
        .update({"lastListened": episodeUid});
  }

  doComment(String comment, String episodeUid, int time) async {
    DocRef doc = await firestore
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
      "uid": userBloc!.uid,
      "comment": comment,
      "time": time,
      "lvl": 1,
      "parents": [],
    });

    firestore.collection("users").doc(userBloc!.uid).update({
      "comments": FieldValue.arrayUnion([
        {
          "id": doc.id,
          "comment": comment,
          "time": time,
          "uid": episodeUid,
          "timestamp": date,
          "lvl": 1,
          "parents": [],
        }
      ]),
    });
    incrementPodcastCounter(episodeUid);
    // doReply(Comment(doc.id, uid: episodeUid, timestamp: date, comment: comment, time: time, lvl: 1, parents: []), "reply");

  }

  doReply(Comment comment, String reply) async {
    DocRef doc = await firestore
        .collection("podcasts")
        .doc(comment.uid)
        .collection("comments")
        .doc();
    String date = DateTime.now().toIso8601String();
    List<String> parents = comment.parents;
    parents.add(comment.id);
    firestore
        .collection("podcasts")
        .doc(comment.uid)
        .collection("comments")
        .doc(doc.id)
        .set({
      "id": doc.id,
      "timestamp": date,
      "uid": userBloc!.uid,
      "comment": reply,
      "time": comment.time,
      "lvl": comment.lvl + 1,
      "parents": parents,
    });

    firestore.collection("users").doc(userBloc!.uid).update({
      "comments": FieldValue.arrayUnion([
        {
          "id": doc.id,
          "comment": reply,
          "time": comment.time,
          "uid": comment.uid,
          "timestamp": date,
          "lvl": comment.lvl + 1,
          "parents": parents,
        }
      ]),
    });
    incrementPodcastCounter(comment.uid);
  }

  incrementPodcastCounter(String episodeUid) {
    firestore.collection("podcasts").doc(episodeUid).update({
      "commentsImg": FieldValue.arrayUnion([userBloc!.image_url]),
      "comments": FieldValue.increment(1)
    });
  }

  followPeople(String uid) {
    String userUid = userBloc!.uid!;
    firestore.collection("users").doc(uid).update({
      "followers": FieldValue.arrayUnion([userUid])
    });
    firestore.collection("users").doc(userUid).update({
      "following": FieldValue.arrayUnion([uid])
    });
  }

  unfollowPeople(String uid) {
    String userUid = userBloc!.uid!;
    firestore.collection("users").doc(uid).update({
      "followers": FieldValue.arrayRemove([userUid])
    });

    firestore.collection("users").doc(userUid).update({
      "following": FieldValue.arrayRemove([uid])
    });
  }

  followShow(String uid) {
    String userUid = userBloc!.uid!;
    firestore.collection("podcasters").doc(uid).update({
      "followers": FieldValue.arrayUnion([userUid])
    });
    firestore.collection("users").doc(userUid).update({
      "favPodcasts": FieldValue.arrayUnion([uid]),
      "following": FieldValue.arrayUnion([uid])
    });
  }

  unfollowShow(String uid) {
    String userUid = userBloc!.uid!;
    firestore.collection("podcasters").doc(uid).update({
      "followers": FieldValue.arrayRemove([userUid])
    });
    firestore.collection("users").doc(userUid).update({
      "favPodcasts": FieldValue.arrayRemove([uid]),
      "following": FieldValue.arrayRemove([uid])
    });
  }

  bool isFollowing(String showUid) {
    return userBloc!.favPodcasts.contains(showUid);
  }
}
