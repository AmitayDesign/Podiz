import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/utils/instances.dart';

import 'firestore_discussion_repository.dart';

final discussionRepositoryProvider = Provider<DiscussionRepository>(
  (ref) => FirestoreDiscussionRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

abstract class DiscussionRepository {
  Stream<List<Comment>> watchEpisodeComments(String episodeId, {int? limit});
  Stream<List<Comment>> watchUserComments(String userId);
  Future<void> addComment(Comment comment);
}

//* Providers

final episodeCommentsStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>(
  (ref, episodeId) =>
      ref.watch(discussionRepositoryProvider).watchEpisodeComments(episodeId),
);
final limitedEpisodeCommentsStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, EpisodeLimit>(
  (ref, episodeLimit) => ref
      .watch(discussionRepositoryProvider)
      .watchEpisodeComments(episodeLimit.episodeId, limit: episodeLimit.limit),
);
final userCommentsStreamProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>(
  (ref, userId) =>
      ref.watch(discussionRepositoryProvider).watchUserComments(userId),
);

//* Argument helper

class EpisodeLimit extends Equatable {
  final String episodeId;
  final int limit;

  const EpisodeLimit(this.episodeId, this.limit);

  @override
  List<Object?> get props => [episodeId, limit];
}
