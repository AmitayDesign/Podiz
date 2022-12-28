import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/alert_dialogs.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/theme/context_theme.dart';

enum CommentMenuOption { edit, delete, report }

extension EnhancedCommentMenuOption on CommentMenuOption {
  String get text {
    switch (this) {
      case CommentMenuOption.edit:
        return 'Edit';
      case CommentMenuOption.delete:
        return 'Delete';
      case CommentMenuOption.report:
        return 'Report Comment';
    }
  }

  IconData get icon {
    switch (this) {
      case CommentMenuOption.edit:
        return Icons.edit;
      case CommentMenuOption.delete:
        return Icons.delete;
      case CommentMenuOption.report:
        return Icons.report_outlined;
    }
  }
}

class CommentMenuButton extends ConsumerWidget {
  final UserPodiz target;
  const CommentMenuButton({Key? key, required this.target}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return PopupMenuButton(
      itemBuilder: (context) => user == target
          ? [
              for (final option in [
                CommentMenuOption.edit,
                CommentMenuOption.delete
              ])
                PopupMenuItem(
                  value: option,
                  child: ListTile(
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      option.text,
                      style: context.textTheme.bodyLarge,
                    ),
                    trailing: Icon(
                      option.icon,
                      size: kSmallIconSize,
                    ),
                  ),
                ),
            ]
          : [
              PopupMenuItem(
                value: CommentMenuOption.report,
                child: ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    CommentMenuOption.report.text,
                    style: context.textTheme.bodyLarge!.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                  trailing: Icon(
                    CommentMenuOption.report.icon,
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            ],
      onSelected: (option) {
        switch (option) {
          case CommentMenuOption.edit:
            //TODO edit comment
            showNotImplementedAlertDialog(context: context);
            break;
          case CommentMenuOption.delete:
            //TODO delete comment
            showNotImplementedAlertDialog(context: context);
            break;
          case CommentMenuOption.report:
            //TODO report comment
            showNotImplementedAlertDialog(context: context);
            break;
        }
      },
    );
  }
}
