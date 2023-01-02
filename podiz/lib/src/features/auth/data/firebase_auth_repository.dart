import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/firestore_refs.dart';
import 'package:podiz/src/utils/in_memory_store.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final SpotifyAPI spotifyApi;

  FirebaseAuthRepository({
    required this.spotifyApi,
    required this.auth,
    required this.firestore,
  }) {
    // listenToConnectionChanges();
    listenToAuthStateChanges();
  }

  void dispose() {
    userSub?.cancel();
    authSub?.cancel();
    // connectionSub?.cancel();
  }

  final authState = InMemoryStore<UserPodiz?>();
  StreamSubscription? userSub;
  StreamSubscription? authSub;
  void listenToAuthStateChanges() {
    authSub?.cancel();
    authSub = auth
        .userChanges()
        .transform(
          StreamTransformer<User?, UserPodiz?>.fromHandlers(
            handleData: (user, sink) {
              userSub?.cancel();
              if (user == null) return sink.add(null);
              spotifyApi.setUserId(user.uid);
              userSub = firestore.usersCollection
                  .doc(user.uid)
                  .snapshots()
                  .listen((doc) {
                final user = UserPodiz.fromFirestore(doc);
                sink.add(user);
              });
            },
            handleDone: (sink) => userSub?.cancel(),
            handleError: (e, _, sink) {
              userSub?.cancel();
              sink.add(null);
            },
          ),
        )
        .listen((user) => authState.value = user);
  }

  @override
  Stream<UserPodiz?> authStateChanges() => authState.stream;

  @override
  UserPodiz? get currentUser => authState.value;

  @override
  Future<String> signInWithSpotify(String code) async {
    try {
      final authToken = await spotifyApi.fetchAuthTokenFromCode(code);
      await auth.signInWithCustomToken(authToken);
      // wait for the user to be fetched before ending the login
      // so it doesnt display a wrong frame
      final user = await authState.stream.firstWhere((user) => user != null);
      return user!.id;
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
    await spotifyApi.disconnect();
  }

  @override
  Future<void> signInWithEmailLink(String email) async {
    auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: 'https://podiz.io',
        androidPackageName: 'com.amitay.podiz',
        iOSBundleId: 'com.amitay.podiz',
        handleCodeInApp: true,
      ),
    );
    //TODO sign in with email link
    //https://firebase.google.com/docs/auth/flutter/email-link-auth
    // auth.signInWithEmailLink(email: email, emailLink: emailLink);
  }

  @override
  Future<void> updateUser(UserPodiz user) async {
    final currentUser = auth.currentUser;
    if (currentUser == null || currentUser.uid != user.id) return;
    if (currentUser.displayName != user.name) {
      await currentUser.updateDisplayName(user.name);
    }
    if (currentUser.email != user.email && user.email != null) {
      // TODO user needs to authenticate again to update the email
      await currentUser.updateEmail(user.email!);
    }
    if (currentUser.photoURL != user.imageUrl) {
      await currentUser.updatePhotoURL(user.imageUrl);
    }
    return firestore.usersCollection
        .doc(user.id)
        .update(user.toJson())
        .catchError((e) => throw Exception('Error updating user'));
  }
}
