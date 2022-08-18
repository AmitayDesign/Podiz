import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment/reply_sheet.dart';
import 'package:podiz/src/features/discussion/presentation/comment_sheet.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';

import 'comment_text.dart';
import 'comment_trailing.dart';
import 'reply_widget.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final String episodeId;
  const CommentCard(this.comment, {Key? key, required this.episodeId})
      : super(key: key);

  void openCommentSheet(BuildContext context, Reader read, Comment comment) {
    read(commentSheetVisibilityProvider.notifier).state = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          read(commentSheetVisibilityProvider.notifier).state = true;
          return true;
        },
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: ReplySheet(
            comment: comment,
            onReply: (reply) async {
              final time = read(playerTimeStreamProvider).valueOrNull!;
              read(discussionRepositoryProvider).addComment(
                reply,
                parent: comment,
                episodeId: episodeId,
                time: time.position,
                user: read(currentUserProvider),
              );
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void share(Comment comment) {} //!

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userValue = ref.watch(userProvider(comment.userId));
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
                      onTap: () => ref
                          .read(playerRepositoryProvider)
                          .resume(episodeId, comment.time ~/ 1000 - 10),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CommentText(comment.text),
                const SizedBox(height: 16),
                CommentTrailing(
                  onReply: () => openCommentSheet(context, ref.read, comment),
                  onShare: () => share(comment),
                ),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  for (final reply in comment.replies.values)
                    ReplyWidget(
                      reply,
                      episodeId: episodeId,
                      onReply: () => openCommentSheet(context, ref.read, reply),
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
