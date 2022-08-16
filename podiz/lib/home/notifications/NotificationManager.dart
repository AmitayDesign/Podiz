import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/src/utils/instances.dart';

final notificationManagerProvider = Provider<NotificationManager>(
  (ref) => NotificationManager(ref.read),
);

class NotificationManager {
  final Reader _read;
  FirebaseFirestore get firestore => _read(firestoreProvider);

  NotificationManager(this._read);

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
        return notificationMap;
      });
}
