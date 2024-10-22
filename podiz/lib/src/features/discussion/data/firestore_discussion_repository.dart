import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';
import 'package:podiz/src/utils/firestore_refs.dart';

import 'discussion_repository.dart';

class FirestoreDiscussionRepository implements DiscussionRepository {
  FirebaseFirestore firestore;
  MixPanelRepository mixPanelRepository;
  FirestoreDiscussionRepository(
      {required this.firestore, required this.mixPanelRepository});

  @override
  Future<Comment> fetchComment(String commentId) async {
    final doc = await firestore.commentsCollection.doc(commentId).get();
    return Comment.fromFirestore(doc);
  }

  @override
  Stream<List<Comment>> watchComments(String episodeId) {
    return firestore.commentsCollection
        .where('episodeId', isEqualTo: episodeId)
        .where('parentIds', isEqualTo: [])
        .where('reported', isEqualTo: false)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Comment.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<Comment>> watchAllLevelComments(String episodeId) {
    return firestore.commentsCollection
        .where('episodeId', isEqualTo: episodeId)
        .where('reported', isEqualTo: false)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    });
  }

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
          // .where('parentIds', isEqualTo: [])
          .orderBy('date', descending: true)
          .snapshots()
          .asyncMap((snapshot) => Future.wait(snapshot.docs.map((doc) async {
                Comment comment = Comment.fromFirestore(doc);
                if (comment.parentIds.isNotEmpty) {
                  comment = await fetchComment(comment.parentIds.first);
                }
                return comment;
              }).toList()));

  @override
  Stream<List<Comment>> watchUserReplies(String userId) =>
      firestore.commentsCollection
          .where('parentUserId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) {
                //! for some reason i cannot do this in the query
                final commentUserId = doc.get('userId');
                return commentUserId != userId;
              })
              .map((doc) => Comment.fromFirestore(doc))
              .toList());

  //TODO just create the comment, do the rest in cloud functions
  // like it is done on the delete method
  @override
  Future<String> addComment(Comment comment) async {
    // generate comment doc to get the id
    final commentDoc = firestore.commentsCollection.doc();

    await firestore.runTransaction((t) async {
      // get episode counters
      final episodeCountersRef =
          firestore.episodeCountersCollection.doc(comment.episodeId);
      final episodeCountersDoc = await t.get(episodeCountersRef);

      // await batch.commit();
      if (comment.parentIds == []) {
        mixPanelRepository.userComment();
      } else {
        mixPanelRepository.userReply();
      }
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
      for (var parentId in comment.parentIds) {
        await firestore.commentsCollection.doc(parentId).update({
          'replyCount': FieldValue.increment(1),
        });
      }
    }, timeout: const Duration(minutes: 1));

    return commentDoc.id;
  }

  @override
  Future<void> updateComment(Comment comment) {
    return firestore.commentsCollection
        .doc(comment.id)
        .update(comment.toJson());
  }

  @override
  Future<void> deleteComment(Comment comment) async {
    // get comment doc
    final commentDoc = firestore.commentsCollection.doc(comment.id);
    await commentDoc.delete();
  }
}
