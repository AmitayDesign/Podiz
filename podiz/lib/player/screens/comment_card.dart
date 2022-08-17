import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/theme/palette.dart';

class CommentCard extends ConsumerStatefulWidget {
  final Comment comment;
  final String episodeId;
  const CommentCard(this.comment, {Key? key, required this.episodeId})
      : super(key: key);

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  final buttonSize = kMinInteractiveDimension * 5 / 6;
  final commentNode = FocusNode();
  final commentController = TextEditingController();
  String get comment => commentController.text;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void sendComment() {}

  @override
  Widget build(BuildContext context) {
    final userValue = ref.watch(userFutureProvider(widget.comment.userId));
    return userValue.when(
      loading: () => SizedBox.fromSize(), //!
      error: (e, _) => const SizedBox.shrink(), //!
      data: (user) {
        return Material(
          color: context.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
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
                      position: widget.comment.time,
                      onTap: () {}, //TODO resume the episode at this time
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.comment.text),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      //TODO similar wth comment sheet content
                      child: TextField(
                        focusNode: commentNode,
                        controller: commentController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.send,
                        minLines: 1,
                        maxLines: 3,
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Palette.grey900,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(
                              kMinInteractiveDimension / 2,
                            ),
                          ),
                          hintText:
                              'Commment on ${user.name.split(' ').first}\'s insight...',
                        ),
                        onSubmitted: (_) => sendComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    //TODO similar wth comment sheet content
                    SizedBox.square(
                      dimension: buttonSize,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: sendComment,
                        child: const Icon(Icons.send, size: kSmallIconSize),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
