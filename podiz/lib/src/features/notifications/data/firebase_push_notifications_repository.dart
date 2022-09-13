import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:podiz/src/features/notifications/domain/notification_podiz.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:podiz/src/utils/firestore_refs.dart';
import 'package:podiz/src/utils/in_memory_store.dart';

import 'push_notifications_repository.dart';

extension RemoteMessageNotificationId on RemoteMessage {
  String get notificationId => data['id'];
  String get channelId => data['channel'];
  String get payload => '$channelId:$notificationId';
}

class FirebasePushNotificationsRepository
    implements PushNotificationsRepository {
  final FlutterLocalNotificationsPlugin plugin;
  final FirebaseMessaging messaging;
  final FirebaseFirestore firestore;

  FirebasePushNotificationsRepository({
    required this.plugin,
    required this.messaging,
    required this.firestore,
  });

  void dispose() {
    tokenSub?.cancel();
    backgroundSub?.cancel();
    foregroundSub?.cancel();
  }

  final channels = {
    'replies': const AndroidNotificationChannel(
      'replies',
      'Replies',
      // description: 'Replies to your comments',
      ledColor: Palette.purple,
      importance: Importance.max,
    ),
    'follows': const AndroidNotificationChannel(
      'follows',
      'Follows',
      // description: 'Replies to your comments',
      ledColor: Palette.purple,
      importance: Importance.max,
    ),
  };

  NotificationDetails details(AndroidNotificationChannel channel) {
    const iosDetails = IOSNotificationDetails();
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
    );
    return NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );
  }

  final selectedNotifications = InMemoryStore<NotificationPodiz>();

  @override
  Future<void> init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_launcher_foreground');

    const IOSInitializationSettings iosSettings = IOSInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await plugin.initialize(settings, onSelectNotification: selectNotification);
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    for (final channel in channels.values) {
      androidPlugin?.createNotificationChannel(channel);
    }
  }

  StreamSubscription? tokenSub;
  @override
  Future<void> requestPermission(String userId) async {
    final permission = await messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      if (token != null) saveToken(token, userId);
      tokenSub?.cancel();
      tokenSub = messaging.onTokenRefresh.listen(
        (token) => saveToken(token, userId),
      );
    }
  }

  Future<void> saveToken(String token, String userId) async {
    await firestore.usersPrivateCollection.doc(userId).set({
      'notificationTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> revokePermission(String userId) async {
    final permission = await messaging.getNotificationSettings();
    if (permission.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      if (token != null) removeToken(token, userId);
    }
  }

  Future<void> removeToken(String token, String userId) async {
    await firestore.usersPrivateCollection.doc(userId).set({
      'notificationTokens': FieldValue.arrayRemove([token]),
    }, SetOptions(merge: true));
  }

  StreamSubscription? foregroundSub;
  StreamSubscription? backgroundSub;
  @override
  Future<void> handleNotifications() async {
    //* foreground
    foregroundSub?.cancel();
    foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    //* background
    backgroundSub?.cancel();
    backgroundSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      selectNotification(message.payload);
    });

    //* terminated
    await messaging.getInitialMessage().then((message) {
      if (message != null) selectNotification(message.payload);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification!.title,
      message.notification!.body,
      details(channels[message.channelId]!),
      payload: message.payload,
    );
  }

  //TODO select different for each channel
  void selectNotification(String? payload) {
    if (payload != null) {
      selectedNotifications.value = NotificationPodiz.fromPayload(payload);
    }
  }

  @override
  Stream<NotificationPodiz> selectedNotificationChanges() =>
      selectedNotifications.stream;
}
