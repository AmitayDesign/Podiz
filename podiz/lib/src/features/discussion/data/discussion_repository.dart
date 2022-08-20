import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firestore_discussion_repository.dart';

final discussionRepositoryProvider = Provider<DiscussionRepository>(
  (ref) => FirestoreDiscussionRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

//TODO make all paginated
abstract class DiscussionRepository {
  Stream<List<Comment>> watchComments(String episodeId);
  Stream<Comment?> watchLastReply(String commentId);
  Stream<List<Comment>> watchReplies(String commentId);
  Stream<List<Comment>> watchUserComments(String userId);
  Stream<List<Comment>> watchUserReplies(String userId);
  Future<void> addComment(Comment comment);
}

//* Providers

final commentsStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>(
  (ref, episodeId) =>
      ref.watch(discussionRepositoryProvider).watchComments(episodeId),
);

final lastReplyStreamProvider =
    StreamProvider.family.autoDispose<Comment?, String>(
  (ref, commentId) =>
      ref.watch(discussionRepositoryProvider).watchLastReply(commentId),
);

final repliesStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>(
  (ref, commentId) =>
      ref.watch(discussionRepositoryProvider).watchReplies(commentId),
);

final userCommentsStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>(
  (ref, userId) =>
      ref.watch(discussionRepositoryProvider).watchUserComments(userId),
);

final userRepliesStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>(
  (ref, userId) =>
      ref.watch(discussionRepositoryProvider).watchUserReplies(userId),
);
