import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/utils/firestore_refs.dart';

import 'discussion_repository.dart';

class FirestoreDiscussionRepository implements DiscussionRepository {
  FirebaseFirestore firestore;
  FirestoreDiscussionRepository({required this.firestore});

  //TODO make this more scalable with paginated list
  @override
  Stream<List<Comment>> watchEpisodeComments(String episodeId, {int? limit}) {
    var episodeComments = firestore.commentsCollection
        .where('episodeId', isEqualTo: episodeId)
        .orderBy('timestamp');
    if (limit != null) episodeComments = episodeComments.limit(limit);
    return episodeComments.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<Comment>> watchUserComments(String userId) {
    return firestore.commentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('episodeId')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  @override
  Future<void> addComment(Comment comment) async {
    // generate comment doc to get the id
    final commentDoc = firestore.commentsCollection.doc();

    final batch = firestore.batch();
    // save comment
    batch.set(commentDoc, comment.toJson());
    // increment episode comment counter
    batch.update(firestore.episodesCollection.doc(comment.episodeId), {
      "commentsCount": FieldValue.increment(1),
    });

    await batch.commit();
  }
}
