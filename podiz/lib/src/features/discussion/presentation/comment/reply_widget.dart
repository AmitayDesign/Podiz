import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/comment_sheet.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'comment_text.dart';
import 'comment_trailing.dart';

class ReplyWidget extends ConsumerWidget {
  final Comment comment;
  final List<Comment> replies;
  final bool collapsed;
  final String episodeId;
  final void Function(Comment comment)? onShare;

  final VoidCallback? onReply;

  const ReplyWidget(
    this.comment, {
    Key? key,
    required this.replies,
    this.collapsed = false,
    required this.episodeId,
    required this.onShare,
    this.onReply,
  }) : super(key: key);

  List<Comment> get directReplies =>
      replies.where((reply) => reply.parentIds.last == comment.id).toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userFutureProvider(comment.userId)).valueOrNull;
    if (user == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              UserAvatar(user: user, radius: 12),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  user.name,
                  style: context.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('${user.followers.length} followers'),
            ],
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              children: [
                if (!collapsed) ...[
                  const VerticalDivider(width: 24),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      CommentText(comment.text),
                      const SizedBox(height: 12),
                      if (!collapsed && comment.parentIds.length < 3) ...[
                        CommentTrailing(
                          onReply: () {
                            ref
                                .read(commentSheetTargetProvider.notifier)
                                .state = comment;
                            onReply?.call();
                          },
                          onShare: () => onShare?.call(comment),
                        ),
                        for (final reply in directReplies)
                          ReplyWidget(
                            reply,
                            episodeId: episodeId,
                            onReply: onReply,
                            onShare: onShare,
                            replies: replies
                                .where((r) => r.parentIds.contains(reply.id))
                                .toList(),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
