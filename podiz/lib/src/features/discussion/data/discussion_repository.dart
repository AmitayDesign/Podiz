import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firestore_discussion_repository.dart';

final discussionRepositoryProvider = Provider<DiscussionRepository>(
  (ref) => FirestoreDiscussionRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

abstract class DiscussionRepository {
  //TODO change how comments are saved
  Stream<List<Comment>> watchComments(String episodeId);
  Stream<List<Comment>> watchUserComments(String userId);
  Future<void> addComment(
    String text, {
    required String episodeId,
    required Duration time,
    required UserPodiz user,
    Comment? parent,
  });
}

//* Providers

final commentsStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>(
  (ref, episodeId) =>
      ref.watch(discussionRepositoryProvider).watchComments(episodeId),
);
final userCommentsStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>(
  (ref, userId) =>
      ref.watch(discussionRepositoryProvider).watchUserComments(userId),
);
