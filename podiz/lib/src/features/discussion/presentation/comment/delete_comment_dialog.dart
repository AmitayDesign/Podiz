import 'package:flutter/material.dart';
import 'package:podiz/src/theme/context_theme.dart';

Future<bool?> showDeleteCommentDialog({
  required BuildContext context,
}) =>
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        title: const Text('Are you sure you want to delete this comment?'),
        titleTextStyle: context.textTheme.bodyLarge,
        actions: [
          TextButton(
            child: Text(
              'Don\'t delete',
              style: context.textTheme.titleSmall,
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(
              'Delete',
              style: context.textTheme.titleSmall!
                  .copyWith(color: context.colorScheme.error),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
