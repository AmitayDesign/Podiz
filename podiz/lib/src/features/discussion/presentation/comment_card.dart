import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/player/screens/reply_sheet.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/circle_button.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/reply_button.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'reply_widget.dart';

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
                Linkify(
                  options: const LinkifyOptions(removeWww: true),
                  onOpen: (link) async {
                    if (await canLaunchUrlString(link.url)) {
                      await launchUrlString(link.url);
                    }
                  },
                  text: comment.text,
                  style: context.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
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
