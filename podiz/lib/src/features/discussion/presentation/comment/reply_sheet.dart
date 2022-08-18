import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/theme/palette.dart';

import 'comment_text_field.dart';

class ReplySheet extends ConsumerWidget {
  final Comment comment;
  final ValueSetter<String>? onReply;
  const ReplySheet({Key? key, required this.comment, this.onReply})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Palette.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kBorderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: CommentTextField(
          autofocus: true,
          hint: 'Add a reply...',
          onSend: onReply,
        ),
      ),
    );
  }
}
