import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
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
    Doc docRef = await firestore.collection("users").doc(userUid).get();
    UserPodiz user = UserPodiz.fromJson(docRef.data()!);
    user.uid = userUid;
    users.addAll({userUid: user});
    return user;
  }
}
