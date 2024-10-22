import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_text.dart';
import 'package:podiz/src/theme/context_theme.dart';

class TargetComment extends ConsumerWidget {
  final Comment comment;
  const TargetComment(this.comment, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userValue = ref.watch(userFutureProvider(comment.userId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        userValue.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (user) {
            return Row(
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
            );
          },
        ),
        const SizedBox(height: 8),
        CommentText(comment.text),
      ],
    );
  }
}
