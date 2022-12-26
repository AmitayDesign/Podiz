import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

final authProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final functionsProvider = Provider<FirebaseFunctions>(
  (ref) => FirebaseFunctions.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final databaseProvider = Provider<FirebaseDatabase>(
  (ref) => FirebaseDatabase.instance,
);
final messagingProvider = Provider<FirebaseMessaging>(
  (ref) => FirebaseMessaging.instance,
);
final localNotificationsProvider = Provider<FlutterLocalNotificationsPlugin>(
  (ref) => FlutterLocalNotificationsPlugin(),
);

final preferencesProvider = Provider<StreamingSharedPreferences>(
  // * Override this in the main method
  (ref) => throw UnimplementedError(),
);
