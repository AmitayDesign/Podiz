import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:podiz/src/features/discussion/data/presence_repository.dart';

class DatabasePresenceRepository implements PresenceRepository {
  final FirebaseDatabase database;
  final FirebaseFirestore firestore;

  DatabasePresenceRepository({
    required this.database,
    required this.firestore,
  });

  void dispose() {
    sub?.cancel();
  }

  DatabaseReference userRef(String userId) => database.ref('users/$userId');
  DatabaseReference connectionsRef(String userId) =>
      userRef(userId).child('connections');
  DatabaseReference lastListenedRef(String userId) =>
      userRef(userId).child('lastListened');

  StreamSubscription? sub;
  @override
  Future<void> configureUserPresence(String userId, String episodeId) async {
    await database.goOnline();

    userRef(userId).onValue.listen((_) {});

    final connectedRef = database.ref('.info/connected');
    sub?.cancel();
    sub = connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        final con = connectionsRef(userId).push();

        // When this device disconnects, remove it.
        con.onDisconnect().remove();

        // update the episode I'm listenning to
        lastListenedRef(userId).set(episodeId);

        // Add this device to my connections list
        // this value could contain info about the device or a timestamp too
        con.set(true);
      }
    });
  }

  @override
  Future<void> updateLastListened(String userId, String episodeId) {
    return lastListenedRef(userId).set(episodeId);
  }

  @override
  Future<void> disconnect() {
    return database.goOffline();
  }
}
