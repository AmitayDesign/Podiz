import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/skeleton_podcast_avatar.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonPodcastCard extends StatelessWidget {
  const SkeletonPodcastCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium!;
    final titleHeight = titleStyle.fontSize! * (titleStyle.height ?? 1);
    final subtitleStyle = context.textTheme.bodyMedium!;
    final subtitleHeight =
        subtitleStyle.fontSize! * (subtitleStyle.height ?? 1);
    return Card(
      color: context.theme.cardColor.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: SkeletonItem(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonPodcastAvatar(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SkeletonLine(
                        style: SkeletonLineStyle(height: titleHeight),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SkeletonLine(
                style: SkeletonLineStyle(height: subtitleHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
