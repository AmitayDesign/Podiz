import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/player/screens/reply_sheet.dart';
import 'package:podiz/player/screens/reply_widget.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/theme/palette.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final String episodeId;
  const CommentCard(this.comment, {Key? key, required this.episodeId})
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
      //! call this later
      loading: () => SizedBox.fromSize(), //!
      error: (e, _) => const SizedBox.shrink(), //!
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
                      onTap: () {}, //TODO resume the episode at this time
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(comment.text, style: context.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox.fromSize(
                        size: Size.fromHeight(buttonSize),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Palette.grey900,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () => openCommentSheet(context),
                          child: Text(
                            'Add a comment...',
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    //TODO similar wth comment sheet content
                    SizedBox.square(
                      dimension: buttonSize,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black87,
                          elevation: 0,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: share,
                        child: const Icon(Icons.share, size: kSmallIconSize),
                      ),
                    ),
                  ],
                ),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  for (final reply in comment.replies.values)
                    ReplyWidget(reply, episodeId: episodeId),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
