import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';

import 'discussion_repository.dart';

class FirestoreDiscussionRepository implements DiscussionRepository {
  FirebaseFirestore firestore;
  FirestoreDiscussionRepository({required this.firestore});

  //TODO make this more scalable
  //! do like a paginated list and when no more comments added, fetch more
  @override
  Stream<List<Comment>> watchComments(String episodeId) {
    return firestore
        .collection('podcasts')
        .doc(episodeId)
        .collection('comments')
        .orderBy('lvl')
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
      final commentList =
          snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
      return groupComments(commentList);
    });
  }

  List<Comment> groupComments(List<Comment> comments) {
    final commentsGroup = <String, Comment>{};
    for (final comment in comments) {
      switch (comment.lvl) {
        case 1:
          commentsGroup[comment.id] = comment;
          break;
        case 2:
          commentsGroup[comment.parentIds[0]]!.replies[comment.id] = comment;
          break;
        case 3:
          commentsGroup[comment.parentIds[0]]!
              .replies[comment.parentIds[1]]!
              .replies[comment.id] = comment;
          break;
        case 4:
          commentsGroup[comment.parentIds[0]]!
              .replies[comment.parentIds[1]]!
              .replies[comment.parentIds[2]]!
              .replies[comment.id] = comment;
          break;
      }
    }
    return commentsGroup.values.toList();
  }

  @override
  Future<void> addComment(
    String text, {
    required String episodeId,
    required int time,
    required UserPodiz user,
    Comment? parent,
  }) async {
    // generate comment doc to get the id
    final commentDoc = firestore
        .collection("podcasts")
        .doc(episodeId)
        .collection("comments")
        .doc();

    final comment = Comment(
      id: commentDoc.id,
      episodeId: episodeId,
      userId: user.id,
      text: text,
      time: time * 1000,
      lvl: parent == null ? 1 : parent.parentIds.length + 2,
      parentIds:
          parent == null ? <String>[] : (parent.parentIds..add(parent.id)),
    );

    final batch = firestore.batch();
    // add comment to comments list
    batch.set(
      commentDoc,
      comment.toJson(),
    );
    // add comment to user comments list
    batch.update(
        firestore
            .collection("users")
            .doc(user.id)
            .collection('comments')
            .doc(comment.id),
        {
          'comments': FieldValue.arrayUnion([comment.toJson()]),
        });
    // increment podcast comment counter
    //TODO do not save img urls, save user ids
    //! then swap user argument for userId
    batch.update(firestore.collection("podcasts").doc(comment.episodeId), {
      "commentsImg": FieldValue.arrayUnion([user.imageUrl]),
      "comments": FieldValue.increment(1)
    });

    // create notification
    if (parent != null) {
      batch.set(
        firestore
            .collection("users")
            .doc(parent.userId)
            .collection("notifications")
            .doc(),
        comment.toJson(),
      );
    }

    await batch.commit();
  }
}
