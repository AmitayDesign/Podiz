import 'package:flutter/material.dart';
import 'package:podiz/src/common_widgets/circle_button.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

class CommentTrailing extends StatelessWidget {
  final double size;
  final String? text;
  final VoidCallback? onReply;
  final VoidCallback? onShare;

  const CommentTrailing({
    Key? key,
    this.size = 32,
    this.text,
    this.onReply,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox.fromSize(
            size: Size.fromHeight(size),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Palette.grey900,
                elevation: 0,
                shape: const StadiumBorder(),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: onReply,
              child: Text(
                text ?? 'Add a reply...',
                style: context.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        CircleButton(
          color: Colors.black87,
          size: size,
          onPressed: onShare,
          icon: Icons.share_rounded,
        ),
      ],
    );
  }
}
