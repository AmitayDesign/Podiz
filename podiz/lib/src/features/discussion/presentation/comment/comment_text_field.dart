import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/circle_button.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/theme/context_theme.dart';

final commentNodeProvider = Provider<FocusNode>(
  (ref) {
    final node = FocusNode();
    ref.onDispose(node.dispose);
    return node;
  },
);

final commentControllerProvider = Provider<TextEditingController>(
  (ref) {
    final controller = TextEditingController();
    ref.onDispose(controller.dispose);
    return controller;
  },
);

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
  FocusNode get commentNode => ref.read(commentNodeProvider);
  TextEditingController get commentController =>
      ref.read(commentControllerProvider);
  String get comment => commentController.text;

  @override
  void initState() {
    super.initState();
    commentNode.addListener(() {
      if (!mounted) return;
      final episode = ref.read(playerStateChangesProvider).valueOrNull;
      final player = ref.read(playerControllerProvider.notifier);
      episode != null && commentNode.hasFocus
          ? player.pause()
          : player.play(episode!.id);
    });
  }

  @override
  void didUpdateWidget(covariant CommentTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autofocus) commentNode.requestFocus();
  }

  void sendComment() {
    if (comment.isEmpty) return;
    widget.onSend?.call(comment);
    commentController.clear();
    commentNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final commentNode = ref.watch(commentNodeProvider);
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
          icon: Icons.send_rounded,
        ),
      ],
    );
  }
}
