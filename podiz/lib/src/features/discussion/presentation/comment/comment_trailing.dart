import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/circle_button.dart';
import 'package:podiz/src/features/discussion/presentation/comment/like_button.dart';
import 'package:podiz/src/features/discussion/presentation/comment/unlike_button.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

class CommentTrailing extends ConsumerWidget {
  final double size;
  final String? text;
  final VoidCallback? onReply;
  final VoidCallback? onShare;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;
  final bool like;
  final int? number;

  const CommentTrailing(
      {Key? key,
      this.size = 32,
      this.text,
      this.onReply,
      this.onShare,
      this.onLike,
      this.onUnlike,
      required this.like,
      this.number = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: SizedBox.fromSize(
            size: Size.fromHeight(size),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.grey900,
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
        const SizedBox(width: 8),
        like
            ? LikeButton(
                color: Colors.black87,
                size: size,
                onPressed: onLike,
                number: number,
              )
            : UnlikeButton(
                color: Colors.black87,
                size: size,
                onPressed: onUnlike,
                number: number,
              ),
      ],
    );
  }
}
