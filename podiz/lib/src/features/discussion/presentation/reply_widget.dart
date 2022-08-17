import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/player/screens/reply_sheet.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/circle_button.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/reply_button.dart';

class ReplyWidget extends ConsumerWidget {
  final Comment comment;
  final String episodeId;
  const ReplyWidget(this.comment, {Key? key, required this.episodeId})
      : super(key: key);

  final buttonSize = 32.0;

  void openCommentSheet(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: ReplySheet(comment: comment),
        ),
      );

  void share() {} //!

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userValue = ref.watch(userFutureProvider(comment.userId));
    return userValue.when(
      loading: () => SizedBox.fromSize(),
      error: (e, _) => const SizedBox.shrink(),
      data: (user) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
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
                    const VerticalDivider(width: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 4),
                          Text(comment.text,
                              style: context.textTheme.bodyLarge),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ReplyButton(
                                  size: buttonSize,
                                  onPressed: () => openCommentSheet(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleButton(
                                size: buttonSize,
                                onPressed: share,
                                icon: Icons.share,
                              ),
                            ],
                          ),
                          if (comment.replies.isNotEmpty) ...[
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
