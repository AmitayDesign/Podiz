import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/common_widgets/circle_button.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';

class CommentTextField extends StatefulWidget {
  final ValueSetter<String>? onSend;
  const CommentTextField({Key? key, this.onSend}) : super(key: key);

  @override
  State<CommentTextField> createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends State<CommentTextField> {
  final commentNode = FocusNode();
  final commentController = TextEditingController();
  String get comment => commentController.text;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void sendComment() {
    widget.onSend?.call(commentController.text);
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
            return UserAvatar(
              user: user,
              radius: CircleButton.defaultSize / 2,
            );
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
            maxLines: 3,
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
              hintText: 'Share your insight...',
            ),
            onSubmitted: (_) => sendComment(),
          ),
        ),
        const SizedBox(width: 8),
        CircleButton(
          onPressed: sendComment,
          icon: Icons.send,
        ),
      ],
    );
  }
}
