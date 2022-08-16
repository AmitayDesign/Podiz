import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firestore_discussion_repository.dart';

final discussionRepositoryProvider = Provider<DiscussionRepository>(
  (ref) => FirestoreDiscussionRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

abstract class DiscussionRepository {
  Stream<List<Comment>> watchComments(EpisodeId episodeId);
  Future<void> addComment(
    String text, {
    required EpisodeId episodeId,
    required int time,
    required UserPodiz user,
    Comment? parent,
  });
}

//* Providers

final commentsStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, EpisodeId>(
  (ref, episodeId) =>
      ref.watch(discussionRepositoryProvider).watchComments(episodeId),
);
