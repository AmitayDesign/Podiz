import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/utils/firestore_refs.dart';

import 'walkthrough_repository.dart';

class FirebaseWalkthroughRepository implements WalkthroughRepository {
  final FirebaseFirestore firestore;
  FirebaseWalkthroughRepository({required this.firestore});

  @override
  Future<bool> isFirstTime(String userId) {
    return firestore.usersPrivateCollection
        .doc(userId)
        .get()
        .then((user) => user.data()?['showcaseEnabled'] ?? true);
  }

  @override
  Future<void> complete(String userId) {
    return firestore.usersPrivateCollection
        .doc(userId)
        .set({'showcaseEnabled': false});
  }
}
