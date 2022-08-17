import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';

class CommentSheetContent extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController controller;
  final ValueSetter<String>? onSend;

  const CommentSheetContent({
    Key? key,
    this.focusNode,
    required this.controller,
    this.onSend,
  }) : super(key: key);

  final buttonSize = kMinInteractiveDimension * 5 / 6;
  String get comment => controller.text;

  void sendComment() {
    onSend?.call(controller.text);
    controller.clear();
    focusNode?.unfocus();
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
            focusNode: focusNode,
            controller: controller,
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
