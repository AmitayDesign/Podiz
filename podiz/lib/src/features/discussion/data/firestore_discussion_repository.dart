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
          .where('parentIds', isEqualTo: [commentId])
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
          .where('parentIds', isEqualTo: [])
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
          .map((snapshot) => snapshot.docs
              .where((doc) {
                //! for some reason i cannot do this in the query
                final commentUserId = doc.get('userId');
                return commentUserId != userId;
              })
              .map((doc) => Comment.fromFirestore(doc))
              .toList());

  @override
  Future<void> addComment(Comment comment) async {
    // generate comment doc to get the id
    final commentDoc = firestore.commentsCollection.doc();

    await firestore.runTransaction((t) async {
      // get episode counters
      final episodeCountersRef =
          firestore.episodeCountersCollection.doc(comment.episodeId);
      final episodeCountersDoc = await t.get(episodeCountersRef);

      // save comment
      t.set(commentDoc, comment.toJson());

      // increment episode comment counter
      final episodeRef = firestore.episodesCollection.doc(comment.episodeId);
      t.update(episodeRef, {
        'commentsCount': FieldValue.increment(1),
        'weeklyCounter': FieldValue.increment(1),
      });

      // increment episode counters
      final countersData = episodeCountersDoc.data() ?? {};
      final counters =
          (countersData['counters'] as Map?)?.cast<String, int>() ?? {};
      final now = DateTime.now();
      counters.update(
        '${now.year}-${now.month}-${now.day}',
        (count) => ++count,
        ifAbsent: () => 1,
      );
      t.set(
        episodeCountersRef,
        {'counters': counters},
        SetOptions(merge: true),
      );

      // increment parent comments reply counter
      for (final parentId in comment.parentIds) {
        t.update(firestore.commentsCollection.doc(parentId), {
          'replyCount': FieldValue.increment(1),
        });
      }
    });
  }
}
