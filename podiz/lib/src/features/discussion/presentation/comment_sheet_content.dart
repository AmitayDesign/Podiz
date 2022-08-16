import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';

class CommentSheetContent extends StatefulWidget {
  final VoidCallback? onSend;
  const CommentSheetContent({Key? key, this.onSend}) : super(key: key);

  @override
  State<CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends State<CommentSheetContent> {
  final buttonSize = kMinInteractiveDimension * 5 / 6;
  final commentNode = FocusNode();
  final commentController = TextEditingController();
  String get comment => commentController.text;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void sendComment() {
    widget.onSend?.call();
    commentController.clear();
    commentNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
            focusNode: commentNode,
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
    );
  }
}
