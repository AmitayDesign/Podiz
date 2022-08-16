import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/discussion/presentation/comment_sheet_content.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/theme/palette.dart';

class QuickNoteSheet extends StatelessWidget {
  final Episode episode;
  const QuickNoteSheet({Key? key, required this.episode}) : super(key: key);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommentSheetContent(
              onSend: () {
                // ref.read(authManagerProvider).doComment(
                //       commentController.text,
                //       widget.episode.id,
                //       widget.episode.duration,
                //     );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Text(
                //TODO locales text
                "${episode.peopleWatchingCount} listening right now",
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
