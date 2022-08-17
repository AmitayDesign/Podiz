import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/utils/instances.dart';

final playerManagerProvider = Provider<PlayerManager>(
  (ref) => PlayerManager(ref.read),
);

class PlayerManager {
  final Reader _read;

  FirebaseFirestore get firestore => _read(firestoreProvider);

  PlayerManager(this._read);

  Future<void> increment(String podcastId) => firestore
      .collection('podcasts')
      .doc(podcastId)
      .update({'watching': FieldValue.increment(1)});

  Future<void> decrement(String podcastId) => firestore
      .collection('podcasts')
      .doc(podcastId)
      .update({'watching': FieldValue.increment(-1)});
}
