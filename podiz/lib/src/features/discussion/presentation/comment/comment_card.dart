import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/comment_sheet.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'comment_text.dart';
import 'comment_trailing.dart';
import 'reply_widget.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final String episodeId;
  const CommentCard(this.comment, {Key? key, required this.episodeId})
      : super(key: key);

  //? https://pub.dev/packages/share_plus
  void share(Comment comment) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userValue = ref.watch(userFutureProvider(comment.userId));
    return userValue.when(
      loading: () => SizedBox.fromSize(),
      error: (e, _) => const SizedBox.shrink(),
      data: (user) {
        return Material(
          color: context.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      user: user,
                      radius: kMinInteractiveDimension * 5 / 12,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: context.textTheme.titleSmall,
                          ),
                          Text('${user.followers.length} followers'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TimeChip(
                      icon: Icons.play_arrow,
                      position: comment.time ~/ 1000,
                      onTap: () {
                        // just call play() if the episode is NOT playing
                        ref
                            .read(playerRepositoryProvider)
                            .fetchPlayingEpisode()
                            .then(
                          (playingEpisode) {
                            if (playingEpisode?.id != episodeId) {
                              ref
                                  .read(playerRepositoryProvider)
                                  .play(episodeId, comment.time ~/ 1000 - 10);
                            }
                          },
                        );
                        context.goNamed(
                          AppRoute.discussion.name,
                          params: {'episodeId': episodeId},
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CommentText(comment.text),
                const SizedBox(height: 16),
                CommentTrailing(
                  onReply: () => ref
                      .read(commentSheetTargetProvider.notifier)
                      .state = comment,
                  onShare: () => share(comment),
                ),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  for (final reply in comment.replies.values)
                    ReplyWidget(
                      reply,
                      episodeId: episodeId,
                      onReply: () => ref
                          .read(commentSheetTargetProvider.notifier)
                          .state = reply,
                      onShare: () => share(reply),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
