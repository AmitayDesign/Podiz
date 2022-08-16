import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/theme/palette.dart';

import 'comment_sheet.dart';

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
          primary: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Palette.grey900,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(kBorderRadius),
            ),
          ),
          builder: (context) => Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: CommentSheet(episode: episode),
          ),
        ),
        icon: Icon(
          Icons.edit,
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
