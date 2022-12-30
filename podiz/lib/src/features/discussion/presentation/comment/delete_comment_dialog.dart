import 'package:flutter/material.dart';
import 'package:podiz/src/theme/context_theme.dart';

Future<bool?> showCommentDialog({
  required BuildContext context,
  required String title,
  required String cancelActionText,
  required String defaultActionText,
}) =>
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        title: Text(title),
        titleTextStyle: context.textTheme.bodyLarge,
        actions: [
          TextButton(
            child: Text(
              cancelActionText,
              style: context.textTheme.titleSmall,
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(
              defaultActionText,
              style: context.textTheme.titleSmall!
                  .copyWith(color: context.colorScheme.error),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
