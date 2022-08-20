import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/comment_sheet.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'comment_text.dart';
import 'comment_trailing.dart';
import 'reply_widget.dart';

class CommentCard extends ConsumerStatefulWidget {
  final Comment comment;
  final String episodeId;
  final bool navigate;

  const CommentCard(
    this.comment, {
    Key? key,
    required this.episodeId,
    this.navigate = true,
  }) : super(key: key);

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  late final repliesCount = calculateReplies(widget.comment);
  late var collapsed = repliesCount > 1;

  int calculateReplies(Comment comment) {
    if (comment.replies.isEmpty) return 0;
    final repliesCountList = <int>[];
    for (final reply in comment.replies.values) {
      repliesCountList.add(1 + calculateReplies(reply));
    }
    return repliesCountList.reduce((total, count) => total + count);
  }

  void openEpisode() async {
    final playerRepository = ref.read(playerRepositoryProvider);
    context.pushNamed(
      AppRoute.discussion.name,
      params: {'episodeId': widget.episodeId},
    );
    // just call play() if the episode is NOT playing
    final playingEpisode = await playerRepository.fetchPlayingEpisode();
    // play 10 seconds before
    final commentTime = Duration(milliseconds: widget.comment.time);
    const delay = Duration(seconds: 10);
    final playTime = commentTime - delay;

    if (playingEpisode?.id != widget.episodeId) {
      playerRepository.play(widget.episodeId, playTime);
    } else {
      playerRepository.resume(widget.episodeId, playTime);
    }
  }

  //TODO share feature
  void share(Comment comment) {}

  @override
  Widget build(BuildContext context) {
    final userValue = ref.watch(userFutureProvider(widget.comment.userId));
    return userValue.when(
      loading: () => SizedBox.fromSize(),
      error: (e, _) => const SizedBox.shrink(),
      data: (user) {
        return Material(
          color: context.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              position:
                                  Duration(milliseconds: widget.comment.time),
                              onTap: openEpisode),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CommentText(widget.comment.text),
                      const SizedBox(height: 16),
                      CommentTrailing(
                        onReply: () => ref
                            .read(commentSheetTargetProvider.notifier)
                            .state = widget.comment,
                        onShare: () => share(widget.comment),
                      ),
                      if (widget.comment.replies.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                      ],
                    ],
                  ),
                ),
                if (collapsed)
                  InkWell(
                    onTap: () => setState(() => collapsed = false),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        replyWidget(widget.comment.replies.values.first),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            repliesCount == 2
                                ? '1 more reply...'.hardcoded
                                : '${repliesCount - 1} more replies...'
                                    .hardcoded,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  )
                else ...[
                  for (final reply in widget.comment.replies.values)
                    replyWidget(reply),
                  if (repliesCount > 1) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => setState(() => collapsed = true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Collapse comments'.hardcoded,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget replyWidget(Comment reply) => ReplyWidget(
        reply,
        collapsed: collapsed,
        episodeId: widget.episodeId,
        onReply: () =>
            ref.read(commentSheetTargetProvider.notifier).state = reply,
        onShare: () => share(reply),
      );
}
