import 'package:cloud_firestore/cloud_firestore.dart';

typedef Ref = CollectionReference<Map<String, dynamic>>;
typedef DocRef = DocumentReference<Map<String, dynamic>>;

typedef Doc = DocumentSnapshot<Map<String, dynamic>>;

extension FirestoreRefs on FirebaseFirestore {
  Ref get usersCollection => collection('test_users');
  Ref get episodesCollection => collection('test_episodes');
  Ref get showsCollection => collection('test_shows');
  Ref get commentsCollection => collection('comments');
}
