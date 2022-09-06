import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/utils/firestore_refs.dart';

import 'showcase_repository.dart';

class ShowcaseViewRepository implements ShowcaseRepository {
  final FirebaseFirestore firestore;
  ShowcaseViewRepository({required this.firestore});

  @override
  Future<void> disable(String userId) =>
      firestore.usersCollection.doc(userId).update({'showcase': false});
}
