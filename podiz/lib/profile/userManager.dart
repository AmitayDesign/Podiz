import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/providers.dart';

final userManagerProvider = Provider<UserManager>(
  (ref) => UserManager(ref.read),
);

class UserManager {
  final Reader _read;

  FirebaseFirestore get firestore => _read(firestoreProvider);

  Map<String, UserPodiz> users = {};

  UserManager(this._read);

  Future<UserPodiz> getUserFromUid(String userUid) async {
    if (users.containsKey(userUid)) {
      return users[userUid]!;
    }
    final doc = await firestore.collection("users").doc(userUid).get();
    final user = UserPodiz.fromFirestore(doc);
    users.addAll({user.uid: user});
    return user;
  }

  Query<UserPodiz> usersFirestoreQuery(String filter) =>
      FirebaseFirestore.instance
          .collection("users")
          .where("searchArray", arrayContains: filter.toLowerCase())
          .withConverter(
            fromFirestore: (user, _) => UserPodiz.fromFirestore(user),
            toFirestore: (podcast, _) => {},
          );
}
