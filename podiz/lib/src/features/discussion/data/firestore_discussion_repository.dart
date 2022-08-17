import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';

import 'discussion_repository.dart';

class FirestoreDiscussionRepository implements DiscussionRepository {
  FirebaseFirestore firestore;
  FirestoreDiscussionRepository({required this.firestore});

  @override
  Stream<List<Comment>> watchComments(EpisodeId episodeId) {
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
      debugPrint(commentList[17].toJson().toString());
      debugPrint(commentList[18].toJson().toString());
      debugPrint(commentList[19].toJson().toString());
      return commentList;
      // return groupComments(commentList);
    });
  }

  //! make this more scalable
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
    required EpisodeId episodeId,
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
      time: time,
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
      firestore.collection("users").doc(user.id),
      comment.toJson(),
    );
    // increment podcast comment counter
    //TODO do not save img urls
    //! then remove user argument
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
