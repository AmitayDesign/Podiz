import 'package:flutter/material.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonCommentCard extends StatelessWidget {
  final double? bottomHeight;
  const SkeletonCommentCard({Key? key, this.bottomHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleSmall!;
    final titleHeight = titleStyle.fontSize! * (titleStyle.height ?? 1);
    final subtitleStyle = context.textTheme.bodyMedium!;
    final subtitleHeight =
        subtitleStyle.fontSize! * (subtitleStyle.height ?? 1);

    return Material(
      color: context.colorScheme.surface.withOpacity(0.5),
      child: SkeletonItem(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            width: kMinInteractiveDimension * 5 / 6,
                            height: kMinInteractiveDimension * 5 / 6,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLine(
                                style: SkeletonLineStyle(height: titleHeight),
                              ),
                              const SizedBox(height: 4),
                              SkeletonLine(
                                style:
                                    SkeletonLineStyle(height: subtitleHeight),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        //!
                        SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            width: 60,
                            height: 24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: subtitleHeight),
                    ),
                    const SizedBox(height: 4),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: subtitleHeight),
                    ),
                    const SizedBox(height: 4),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: subtitleHeight),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SkeletonLine(
                            style: SkeletonLineStyle(
                              height: 32,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            width: 32,
                            height: 32,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
