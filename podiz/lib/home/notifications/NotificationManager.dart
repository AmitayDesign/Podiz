import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/providers.dart';

final notificationManagerProvider = Provider<NotificationManager>(
  (ref) => NotificationManager(
    firestore: ref.watch(firestoreProvider),
  ),
);

class NotificationManager {
  final FirebaseFirestore firestore;

  NotificationManager({
    required this.firestore,
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
        Map<String, List<NotificationPodiz>> notificationMap = {};
        for (int i = 0; i < snapshot.docs.length; i++) {
          NotificationPodiz not =
              NotificationPodiz.fromFirestore(snapshot.docs[i]);
          if (notificationMap.containsKey(not.episodeUid)) {
            notificationMap[not.episodeUid]!.add(not);
          } else {
            notificationMap.addAll({
              not.episodeUid: [not]
            });
          }
        }
        // final notificationList = snapshot.docs.map((doc) =>
        //     NotificationPodiz.fromFirestore(doc));
        //  Map.fromIterable(notificationList, key: (n) => n.episodeUid);

        return notificationMap;
      });
}
