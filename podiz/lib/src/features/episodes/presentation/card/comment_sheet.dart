import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';

class CommentSheet extends ConsumerStatefulWidget {
  final Podcast podcast;
  const CommentSheet({Key? key, required this.podcast}) : super(key: key);

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final buttonSize = kMinInteractiveDimension * 5 / 6;
  final commentController = TextEditingController();
  String get comment => commentController.text;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void sendComment() {
    ref.read(authManagerProvider).doComment(
          commentController.text,
          widget.podcast.uid!,
          widget.podcast.duration_ms,
        );
    // commentController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(currentUserProvider);
                  return UserAvatar(user: user, radius: buttonSize / 2);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: commentController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 5,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(
                        kMinInteractiveDimension / 2,
                      ),
                    ),
                    hintText: "Share your insight...",
                  ),
                  onSubmitted: (_) => sendComment(),
                ),
              ),
              const SizedBox(width: 8),
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Text(
              //TODO locales text
              "${widget.podcast.watching} listening right now",
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
