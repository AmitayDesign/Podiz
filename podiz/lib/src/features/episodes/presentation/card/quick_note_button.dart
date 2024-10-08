import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/comment_sheet.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/theme/context_theme.dart';

class QuickNoteButton extends StatelessWidget {
  final Episode episode;
  const QuickNoteButton({Key? key, required this.episode}) : super(key: key);

  static const height = 32.0;

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.bodySmall;
    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: CommentSheet(episode),
          ),
        ),
        icon: Icon(
          Icons.edit_rounded,
          size: kSmallIconSize,
          color: textStyle!.color,
        ),
        label: Text(
          Locales.string(context, "quicknote"),
          style: textStyle,
        ),
      ),
    );
  }
}
