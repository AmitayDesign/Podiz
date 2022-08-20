import 'package:cloud_firestore/cloud_firestore.dart';

typedef Ref = CollectionReference<Map<String, dynamic>>;
typedef DocRef = DocumentReference<Map<String, dynamic>>;

typedef Doc = DocumentSnapshot<Map<String, dynamic>>;

extension FirestoreRefs on FirebaseFirestore {
  Ref get usersCollection => collection('users');
  Ref get episodesCollection => collection('episodes');
  Ref get showsCollection => collection('shows');
  Ref get commentsCollection => collection('comments');
}
