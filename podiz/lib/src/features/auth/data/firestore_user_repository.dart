import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore firestore;
  const FirestoreUserRepository({required this.firestore});

  @override
  Stream<UserPodiz> watchUser(String userId) {
    return firestore
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((doc) => UserPodiz.fromFirestore(doc));
  }

  @override
  Future<UserPodiz> fetchUser(String userId) async {
    final doc = await firestore.collection("users").doc(userId).get();
    return UserPodiz.fromFirestore(doc);
  }

  @override
  Query<UserPodiz> usersFirestoreQuery(String filter) =>
      FirebaseFirestore.instance
          .collection("users")
          .where("searchArray", arrayContains: filter.toLowerCase())
          .withConverter(
            fromFirestore: (user, _) => UserPodiz.fromFirestore(user),
            toFirestore: (podcast, _) => {},
          );
}
