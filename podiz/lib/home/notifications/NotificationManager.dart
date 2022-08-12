import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final notificationManagerProvider = Provider<NotificationManager>(
  (ref) {
    final manager = NotificationManager(
      firestore: ref.watch(firestoreProvider),
      authManager: ref.watch(authManagerProvider),
    );
    ref.onDispose(manager.dispose);
    return manager;
  },
);

class NotificationManager {
  final FirebaseFirestore firestore;
  final AuthManager authManager;

  NotificationManager({
    required this.firestore,
    required this.authManager,
  }) {
    String userUid = authManager.currentUser!.uid;
    firestore
        .collection("users")
        .doc(userUid)
        .collection("notifications")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snapshot) async {
      for (DocChange notificationChange in snapshot.docChanges) {
        if (notificationChange.type == DocumentChangeType.added) {
          await addNotificationToBloc(notificationChange.doc);
        }
      }
      _notificationStream.add(notificationBloc);
    });
  }

  void dispose() {}

  Map<String, List<NotificationPodiz>> notificationBloc = {};

  final _notificationStream =
      BehaviorSubject<Map<String, List<NotificationPodiz>>>();
  Stream<Map<String, List<NotificationPodiz>>> get notifications =>
      _notificationStream.stream;

  // General Functions

  Future<void> addNotificationToBloc(Doc doc) async {
    NotificationPodiz notification = NotificationPodiz.fromJson(doc.data()!);
    notification.uid = doc.id;
    if (notificationBloc.containsKey(notification.episodeUid)) {
      notificationBloc[notification.episodeUid]!.add(notification);
    } else {
      notificationBloc.addAll({
        notification.episodeUid: [notification]
      });
    }
  }
}
