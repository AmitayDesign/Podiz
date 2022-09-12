import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/utils/doc_typedef.dart';

extension FirestoreRefs on FirebaseFirestore {
  Ref get usersCollection => collection('users');
  Ref get episodesCollection => collection('episodes');
  Ref get episodeCountersCollection => collection('episodeCounters');
  Ref get showsCollection => collection('shows');
  Ref get commentsCollection => collection('comments');
  Ref get usersPrivateCollection => collection('usersPrivate');
}
