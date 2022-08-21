import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
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
  late var collapsed = widget.comment.replyCount > 1;

  void openEpisode() async {
    final playerRepository = ref.read(playerRepositoryProvider);
    context.pushNamed(
      AppRoute.discussion.name,
      params: {'episodeId': widget.episodeId},
    );
    // just call play() if the episode is NOT playing
    final playingEpisode = await playerRepository.fetchPlayingEpisode();
    // play 10 seconds before
    const delay = Duration(seconds: 10);
    final playTime = widget.comment.timestamp - delay;

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
                            position: widget.comment.timestamp,
                            onTap: openEpisode,
                          ),
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
                      if (widget.comment.replyCount > 0) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                      ],
                    ],
                  ),
                ),
                if (collapsed)
                  Consumer(builder: (context, ref, _) {
                    final lastReply = ref
                        .watch(lastReplyStreamProvider(widget.comment.id))
                        .valueOrNull;
                    if (lastReply == null) return const SizedBox.shrink();
                    return InkWell(
                      onTap: () => setState(() => collapsed = false),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          replyWidget(lastReply),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              widget.comment.replyCount == 2
                                  ? '1 more reply...'.hardcoded
                                  : '${widget.comment.replyCount - 1} more replies...'
                                      .hardcoded,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  })
                else
                  Consumer(
                    builder: (context, ref, _) {
                      final replies = ref
                          .watch(repliesStreamProvider(widget.comment.id))
                          .valueOrNull;
                      if (replies == null) return const SizedBox.shrink();
                      final directReplies = replies.where(
                        (reply) => reply.parentIds.last == widget.comment.id,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final reply in directReplies)
                            replyWidget(
                              reply,
                              replies
                                  .where((reply) =>
                                      reply.parentIds.contains(reply.id))
                                  .toList(),
                            ),
                          if (widget.comment.replyCount > 1) ...[
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
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget replyWidget(
    Comment reply, [
    List<Comment> replies = const [],
  ]) =>
      ReplyWidget(
        reply,
        replies: replies,
        collapsed: collapsed,
        episodeId: widget.episodeId,
        onReply: () =>
            ref.read(commentSheetTargetProvider.notifier).state = reply,
        onShare: () => share(reply),
      );
}
