import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/providers.dart';

final notificationManagerProvider = Provider<NotificationManager>(
  (ref) => NotificationManager(ref.read),
);

class NotificationManager {
  final Reader _read;
  FirebaseFirestore get firestore => _read(firestoreProvider);

  NotificationManager(this._read);

  Stream<Map<String, List<NotificationPodiz>>> watchNotifications(
    String userId,
  ) {
    return firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) {
      final notificationList =
          snapshot.docs.map((doc) => NotificationPodiz.fromFirestore(doc));
      return Map.fromIterable(notificationList, key: (n) => n.episodeUid);
    });
  }
}
