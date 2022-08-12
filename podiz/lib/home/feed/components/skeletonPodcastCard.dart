import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/home/components/skeletonPodcastAvatar.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonPodcastCard extends StatelessWidget {
  final double? bottomHeight;
  const SkeletonPodcastCard({Key? key, this.bottomHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium!;
    final titleHeight = titleStyle.fontSize! * (titleStyle.height ?? 1);
    final subtitleStyle = context.textTheme.bodyMedium!;
    final subtitleHeight =
        subtitleStyle.fontSize! * (subtitleStyle.height ?? 1);

    return Card(
      color: context.theme.cardColor.withOpacity(0.5),
      margin: const EdgeInsets.all(8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: SkeletonItem(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .add(const EdgeInsets.only(top: 8, bottom: 12)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Row(
                  children: [
                    const SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        width: 32,
                        height: 32,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SkeletonLine(
                        style: SkeletonLineStyle(height: subtitleHeight),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonPodcastAvatar(size: 64),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLine(
                            style: SkeletonLineStyle(height: titleHeight),
                          ),
                          const SizedBox(height: 4),
                          SkeletonLine(
                            style: SkeletonLineStyle(height: titleHeight),
                          ),
                          const SizedBox(height: 4),
                          SkeletonLine(
                            style: SkeletonLineStyle(height: subtitleHeight),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (bottomHeight != null) ...[
                const SizedBox(height: 12),
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: bottomHeight,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
