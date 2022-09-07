import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/comment_sheet.dart';
import 'package:podiz/src/theme/context_theme.dart';

class ErrorCommentSheet extends StatelessWidget {
  const ErrorCommentSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CommentSheet.height,
      child: Material(
        color: context.colorScheme.errorContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox.square(
                dimension: kMinInteractiveDimension,
                child: Center(
                  child: Icon(Icons.error_outline),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Something went wrong.',
                  style: TextStyle(
                    color: context.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
