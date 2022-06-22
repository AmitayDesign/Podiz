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
  // AppManager get appManager => _read(appManagerProvider);
  // EStoreManager get eStoreManager => _read(eStoreManagerProvider);
  // OrderManager get orderManager => _read(orderManagerProvider);
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
    podcastManager.setUpPodcastStream();
    showManager.setUpShowStream();
    try {
      if (await FileHandler.fileExists("user.txt")) {
        final json = await FileHandler.readFromFile("user.txt");
        userBloc = UserPodiz.fromJson(json!);
        _userStream.add(userBloc);
        await _fetchUserInfo(userBloc!.uid);
      } else {
        _userStream.add(null);
      }
    } catch (e) {
      return "error";
    }
    if (!_userCompleter.isCompleted) _userCompleter.complete();
  }

  _fetchUserInfo(String userID) async {
    final userReference = firestore.collection('user').doc(userID);
    Doc userData = await userReference.get();
    int totalTimeWaiting = 0;
    while (userData.data() == null && totalTimeWaiting < 2000) {
      await Future.delayed(Duration(milliseconds: 100));
      userData = await userReference.get();
      totalTimeWaiting += 100;
    }

    if (userData.data() == null) {
      //TODO couldnt login
      return;
    }

    try {
      userBloc = UserPodiz.fromFirestore(userData);
    } on Exception catch (_) {
      print("EXCEPTION WTF");
    }
    await saveUser();
    await setUpUserStream();
    // podcastManager.setUpPodcastStream();
    // await orderManager.setUpOrders(userBloc!.uid);
  }

  _emptyManagers() {
    podcastManager.resetManager();
    // orderManager.inOrdersEvent.add("empty orders"); //TODO  change to function

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

  setUpUserStream() async {
    firestore
        .collection("user")
        .doc(userBloc!.uid)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        userBloc = UserPodiz.fromFirestore(snapshot);
        saveUser();
        _userStream.add(userBloc);
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
          .collection('user')
          .doc(firebaseAuth.currentUser!.uid)
          .update(user.toJson());
    } catch (_) {
      throw Failure.unexpected(context);
    }
  }

  Future<void> registerUserAndPassFirebase(
    BuildContext context, {
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userRef = firestore
          .collection('user')
          .doc(userCredential.user!.uid)
          .set({
        "name": name,
        "email": email,
        "timestamp": DateTime.now().toString()
      });

      await _fetchUserInfo(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw AuthFailure.weekPassword(context);
        case 'email-already-in-use':
          throw AuthFailure.emailAlreadyInUse(context);
        default:
          print(e.code);
          throw Failure.unexpected(context);
      }
    }
  }

  Future<void> signInUserAndPassFirebase(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _fetchUserInfo(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw AuthFailure.wrongPassword(context);
        case 'user-not-found':
        case 'invalid-email':
          throw AuthFailure.userNotFound(context);
        case 'too-many-requests':
          throw AuthFailure.tooManyRequests(context);
        default:
          print(e.code);
          throw Failure.unexpected(context);
      }
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
          throw AuthFailure.userNotFound(context);
        default:
          throw Failure.unexpected(context);
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _emptyManagers();
    await firebaseAuth.signOut();
    await deleteUserFile();
  }

  Future<void> requestUserData(Map<String, String> request, context) async {
    //TODO review (had a loading before)
    await firestore.collection("clientInfo").doc(userBloc!.uid).set(request);
    Navigator.pop(context);
  } //GDPR conserns
}
