// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:podiz/aspect/theme/palette.dart';
// import 'package:podiz/authentication/AuthManager.dart';
// import 'package:podiz/providers.dart';

// class PushNotificationService {
//   late final Reader _read;
//   FirebaseMessaging get _messaging => FirebaseMessaging.instance;
//   FirebaseFirestore get firestore => _read(firestoreProvider);
//   AuthManager get authManager => _read(authManagerProvider);

//   FlutterLocalNotificationsPlugin get _local =>
//       FlutterLocalNotificationsPlugin();

//   PushNotificationService._();
//   static final PushNotificationService instance = PushNotificationService._();

//   //! CALLED BEFORE RUNAPP SO I CAN USE PROVIDERS HERE
//   void init(Reader read) => _read = read;
//   final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
//     'general',
//     'general channel',
//     importance: Importance.max,
//     ledColor: Palette.purple,
//   );

//   late final _details = NotificationDetails(
//     android: AndroidNotificationDetails(
//       _channel.id,
//       _channel.name,
//       importance: _channel.importance,
//       priority: Priority.high,
//     ),
//   );

//   /* HELPERS */

//   Future<String?> getToken() => _messaging.getToken();

//   /* ACTIONS */

//   //! CALLED RIGHT AFTER LOGGING IN
//   Future<void> saveDevice() async {
//     final permission = await _messaging.requestPermission();
//     if (permission.authorizationStatus == AuthorizationStatus.authorized) {
//       final token = await getToken();
//       if (token != null) await _saveToken(token);
//       _messaging.onTokenRefresh.listen(_saveToken);
//     }
//   }

//   //! CALLED RIGHT AFTER LOGGING OUT
//   Future<void> removeDevice() async {
//     final permission = await _messaging.getNotificationSettings();
//     if (permission.authorizationStatus == AuthorizationStatus.authorized) {
//       final token = await getToken();
//       if (token != null) await _removeToken(token);
//     }
//   }

//   Future<void> _saveToken(String token) async {
//     String userId = authManager.userBloc!.uid!;
//     await firestore
//         .collection("notifications")
//         .doc(userId)
//         .set({'token': token});
//   }

//   Future<void> _removeToken(String token) async {
//     String userId = authManager.userBloc!.uid!;
//     await firestore
//         .collection("notifications")
//         .doc(userId)
//         .set({'token': token});
//   }

//   //! CALLED ON MYAPP INITSTATE SO IT CAN HANDLE NOTIFICATIONS
//   Future<void> onNotification() async {
//     await _setup();

//     //* terminated
//     // ignore: unawaited_futures
//     _messaging.getInitialMessage().then((message) {
//       if (message != null) notificationId = message.data['id'];
//     });

//     //* background
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       notificationId = message.data['id'];
//     });

//     //* foreground
//     FirebaseMessaging.onMessage.listen((message) {
//       _display(message);
//     });
//   }

//   Future<void> _setup() async {
//     await _local.initialize(
//       InitializationSettings(android: AndroidInitializationSettings('tray')),
//       onSelectNotification: (id) => notificationId = id!,
//     );
//     await _local
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channel);
//   }

//   void _display(RemoteMessage message) => _local.show(
//         DateTime.now().millisecondsSinceEpoch ~/ 1000,
//         message.notification!.title,
//         message.notification!.body,
//         _details,
//         payload: message.data['id'],
//       );

//   // set notificationId(String id) =>
//   //     _read(pushNotificationProvider.state).state = id;

//   // void listen(BuildContext context, WidgetRef ref) =>
//   //     ref.listen<String?>(pushNotificationProvider, (_, id) {
//   //       if (id == null) return;
//   //       final notification = ref.read(notificationProvider(id));
//   //       Future.microtask(() => notification?.navigate(context, ref));
//   //     });
// }