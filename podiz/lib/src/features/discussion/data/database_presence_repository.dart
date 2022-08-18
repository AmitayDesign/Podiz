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

  StreamSubscription? sub;
  @override
  Future<void> configureUserListeningPresence(
    String userId,
    String episodeId,
  ) async {
    // Since I can connect from multiple devices, we store each connection
    // instance separately any time that connectionsRef's value is null (i.e.
    // has no children) I am offline.
    final myConnectionsRef = database.ref('users/$userId/connections');

    // Stores the timestamp of my last disconnect
    // (the last time I was seen online)
    final myLastListenedRef = database.ref('users/$userId/lastListened');

    await database.goOnline();

    final connectedRef = database.ref('.info/connected');
    sub = connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        final con = myConnectionsRef.push();

        // When this device disconnects, remove it.
        con.onDisconnect().remove();

        // update the episode I'm listenning to
        myLastListenedRef.set(episodeId);

        // Add this device to my connections list
        // this value could contain info about the device or a timestamp too
        con.set(true);
      }
    });
  }

  @override
  Future<void> disconnect() => database.goOffline();
}
