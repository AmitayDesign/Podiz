import 'dart:async';

import 'package:podiz/aspect/failures/authFailure.dart';
import 'package:podiz/aspect/failures/failure.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/home/search/showManager.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/services/fileHandler.dart';

import 'package:podiz/home/search/podcastManager.dart';
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
    await podcastManager.setUpPodcastStream();
    await showManager.setUpShowStream();
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
    firestore.collection("users").doc(uid).snapshots().listen((snapshot) async {
      if (snapshot.data() != null) {
        userBloc = UserPodiz.fromJson(snapshot.data()!);
        userBloc!.uid = uid;
        await saveUser();
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
}
