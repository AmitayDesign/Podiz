import 'package:flutter/material.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

/// Generic function to show a Material dialog
Future<bool?> showAlertDialog({
  required BuildContext context,
  required String title,
  String? content,
  String? cancelActionText,
  String? defaultActionText,
}) =>
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        title: Text(title),
        titleTextStyle: context.textTheme.titleMedium,
        content: content != null ? Text(content) : null,
        contentTextStyle: context.textTheme.bodyMedium,
        actions: [
          if (cancelActionText != null)
            TextButton(
              child: Text(
                cancelActionText,
                style: context.textTheme.titleSmall!
                    .copyWith(color: Palette.purple),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          TextButton(
            child: Text(
              defaultActionText ?? 'Ok'.hardcoded,
              style:
                  context.textTheme.titleSmall!.copyWith(color: Palette.purple),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

/// Generic function to show a platform-aware Material or Cupertino error dialog
Future<void> showExceptionAlertDialog({
  required BuildContext context,
  required String title,
  required dynamic exception,
}) =>
    showAlertDialog(
      context: context,
      title: title,
      content: exception.toString(),
    );

Future<void> showNotImplementedAlertDialog({required BuildContext context}) =>
    showAlertDialog(
      context: context,
      title: 'Not implemented'.hardcoded,
    );
