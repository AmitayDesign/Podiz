import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_card.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';

import 'episode_subtitle.dart';

class GroupedComments extends ConsumerWidget {
  final String episodeId;
  final List<Comment> comments;

  const GroupedComments(this.episodeId, this.comments, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeValue = ref.watch(episodeFutureProvider(episodeId));
    return episodeValue.when(
      loading: () => const SizedBox.shrink(), //!
      error: (e, _) => const SizedBox.shrink(),
      data: (episode) {
        final podcastValue = ref.watch(podcastFutureProvider(episode.showId));
        return podcastValue.when(
          loading: () => const SizedBox.shrink(), //!
          error: (e, _) => const SizedBox.shrink(),
          data: (podcast) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EpisodeSubtitle(episode, podcast),
                  for (final comment in comments)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CommentCard(
                        comment,
                        episodeId: episodeId,
                        navigate: true,
                      ),
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
