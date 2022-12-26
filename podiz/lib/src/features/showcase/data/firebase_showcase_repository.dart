import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/utils/firestore_refs.dart';

import 'showcase_repository.dart';

class FirebaseShowcaseRepository implements ShowcaseRepository {
  final FirebaseFirestore firestore;
  FirebaseShowcaseRepository({required this.firestore});

  final key = 'firstTimeShowcase';

  @override
  Future<bool> isFirstTime(String userId) => firestore.usersPrivateCollection
      .doc(userId)
      .get()
      .then((user) => user.data()?['showcaseEnabled'] ?? true);

  @override
  Future<void> disable(String userId) =>
      firestore.usersPrivateCollection.doc(userId).set({
        'showcaseEnabled': false,
      });
}
