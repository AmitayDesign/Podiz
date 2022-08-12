import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/providers.dart';

final notificationManagerProvider = Provider<NotificationManager>(
  (ref) => NotificationManager(
    firestore: ref.watch(firestoreProvider),
    authManager: ref.watch(authManagerProvider),
  ),
);

class NotificationManager {
  final FirebaseFirestore firestore;
  final AuthManager authManager;

  NotificationManager({
    required this.firestore,
    required this.authManager,
  });

  Stream<Map<String, List<NotificationPodiz>>> watchNotifications(
          String userId) =>
      firestore
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
