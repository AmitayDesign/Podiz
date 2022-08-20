import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/utils/firestore_refs.dart';

import 'discussion_repository.dart';

class FirestoreDiscussionRepository implements DiscussionRepository {
  FirebaseFirestore firestore;
  FirestoreDiscussionRepository({required this.firestore});

  @override
  Stream<List<Comment>> watchComments(String episodeId) =>
      firestore.commentsCollection
          .where('episodeId', isEqualTo: episodeId)
          .where('parentIds', isEqualTo: [])
          .orderBy('timestamp')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());

  @override
  Stream<Comment?> watchLastReply(String commentId) =>
      firestore.commentsCollection
          .where('parentIds', arrayContains: commentId)
          .orderBy('timestamp')
          .limit(1)
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty
              ? Comment.fromFirestore(snapshot.docs.single)
              : null);

  @override
  Stream<List<Comment>> watchReplies(String commentId) =>
      firestore.commentsCollection
          .where('parentIds', arrayContains: commentId)
          .orderBy('timestamp')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());

  @override
  Stream<List<Comment>> watchUserComments(String userId) =>
      firestore.commentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('episodeId')
          .orderBy('timestamp')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());

  @override
  Stream<List<Comment>> watchUserReplies(String userId) =>
      firestore.commentsCollection
          .where('parentUserId', isEqualTo: userId)
          .orderBy('episodeId')
          .orderBy('timestamp')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());

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
    // increment parent comments reply counter
    for (final parentId in comment.parentIds) {
      batch.update(firestore.commentsCollection.doc(parentId), {
        "replyCount": FieldValue.increment(1),
      });
    }

    await batch.commit();
  }
}
