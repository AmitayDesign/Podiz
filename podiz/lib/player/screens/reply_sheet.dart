import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment_sheet_content.dart';
import 'package:podiz/src/theme/palette.dart';

class ReplySheet extends ConsumerStatefulWidget {
  final Comment comment;
  const ReplySheet({Key? key, required this.comment}) : super(key: key);

  @override
  ConsumerState<ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends ConsumerState<ReplySheet> {
  final commentNode = FocusNode();
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kBorderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: CommentSheetContent(
          focusNode: commentNode..requestFocus(),
          controller: commentController,
          key: UniqueKey(),
          onSend: (text) {
            // comment
          },
        ),
      ),
    );
  }
}
