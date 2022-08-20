import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

const ipv4 = '192.168.1.73';
const specialHost = '10.0.2.2';

final functionsProvider = Provider<FirebaseFunctions>(
  (ref) => FirebaseFunctions.instance,
  //..useFunctionsEmulator(specialHost, 5001),
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
  //..useFirestoreEmulator(specialHost, 8080),
);
final databaseProvider = Provider<FirebaseDatabase>(
  (ref) => FirebaseDatabase.instance,
  //..useDatabaseEmulator(specialHost, 9000),
);
final preferencesFutureProvider = FutureProvider<StreamingSharedPreferences>(
  (ref) => StreamingSharedPreferences.instance,
);
final preferencesProvider = Provider<StreamingSharedPreferences>(
  (ref) => ref.watch(preferencesFutureProvider).value!,
);
