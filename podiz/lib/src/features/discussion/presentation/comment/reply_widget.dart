import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'comment_text.dart';
import 'comment_trailing.dart';

class ReplyWidget extends ConsumerWidget {
  final Comment comment;
  final bool collapsed;
  final String episodeId;
  final VoidCallback? onReply;
  final VoidCallback? onShare;

  const ReplyWidget(
    this.comment, {
    Key? key,
    this.collapsed = false,
    required this.episodeId,
    this.onReply,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userValue = ref.watch(userFutureProvider(comment.userId));
    return userValue.when(
      loading: () => SizedBox.fromSize(),
      error: (e, _) => const SizedBox.shrink(),
      data: (user) {
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
                          if (!collapsed) ...[
                            CommentTrailing(
                              onReply: onReply,
                              onShare: onShare,
                            ),
                            if (comment.replies.isNotEmpty)
                              for (final reply in comment.replies.values)
                                ReplyWidget(reply, episodeId: episodeId),
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
      },
    );
  }
}
