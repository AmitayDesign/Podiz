import 'package:flutter/material.dart';
import 'package:podiz/src/common_widgets/circle_button.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/comment_sheet.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonCommentSheet extends StatelessWidget {
  const SkeletonCommentSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodyMedium!;
    final subtitleHeight =
        subtitleStyle.fontSize! * (subtitleStyle.height ?? 1);

    return SizedBox(
      height: CommentSheet.height,
      child: Material(
        color: Palette.grey900.withOpacity(0.25),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadius),
          ),
        ),
        child: SkeletonItem(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        height: CircleButton.defaultSize,
                        width: CircleButton.defaultSize,
                        borderRadius: BorderRadius.circular(
                          CircleButton.defaultSize / 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SkeletonLine(
                        style: SkeletonLineStyle(
                          height: kMinInteractiveDimension,
                          borderRadius: BorderRadius.circular(
                              kMinInteractiveDimension / 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        height: CircleButton.defaultSize,
                        width: CircleButton.defaultSize,
                        borderRadius: BorderRadius.circular(
                          CircleButton.defaultSize / 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SkeletonLine(
                      style: SkeletonLineStyle(height: subtitleHeight),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
