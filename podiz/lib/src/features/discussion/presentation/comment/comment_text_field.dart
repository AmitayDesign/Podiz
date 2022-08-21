import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/circle_button.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/theme/context_theme.dart';

class CommentTextField extends ConsumerStatefulWidget {
  final bool autofocus;
  final String hint;
  final ValueSetter<String>? onSend;

  const CommentTextField({
    Key? key,
    this.autofocus = false,
    this.hint = 'Share your insight...',
    this.onSend,
  }) : super(key: key);

  @override
  ConsumerState<CommentTextField> createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends ConsumerState<CommentTextField> {
  final commentNode = FocusNode();
  final commentController = TextEditingController();
  String get comment => commentController.text;

  @override
  void dispose() {
    commentNode.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommentTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autofocus) {
      commentNode.requestFocus();
    } else {
      commentNode.unfocus();
    }
  }

  void sendComment() {
    if (comment.isEmpty) return;
    widget.onSend?.call(comment);
    commentController.clear();
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
            autofocus: widget.autofocus,
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
              hintText: widget.hint,
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
