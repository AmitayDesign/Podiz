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
    if (comment.parentIds == []) {
      mixPanelRepository.userComment();
    } else {
      mixPanelRepository.userReply();
    }
  }
}

// await firestore.runTransaction((t) async {
//   // save comment
//   t.set(commentDoc, comment.toJson());

//   // increment episode comment counter
//   final episodeRef = firestore.episodesCollection.doc(comment.episodeId);
//   final episodeDoc = await t.get(episodeRef);
//   final episodeData = episodeDoc.data()!;

//   var weeklyCounter = episodeData['weeklyCounter'];
//   final weekCounters = episodeData['weekCounters'] as Map<String, int>;
//   final now = DateTime.now();

//   // increment todays comments
//   weeklyCounter++;
//   weekCounters.update(formatDate(now), (count) => ++count,
//       ifAbsent: () => 1);

//   // remove comments with more than 7 days
//   if (weekCounters.length > 7) {
//     final dateToRemove = now.subtract(const Duration(days: 7));
//     final count = weekCounters.remove(formatDate(dateToRemove));
//     weeklyCounter -= count;
//   }

//   t.update(episodeRef, {
//     'commentsCount': FieldValue.increment(1),
//     'weeklyCounter': FieldValue.increment(1),
//     'weekCounters': '',
//   });
//   // increment parent comments reply counter
//   for (final parentId in comment.parentIds) {
//     t.update(firestore.commentsCollection.doc(parentId), {
//       'replyCount': FieldValue.increment(1),
//     });
//   }
// });