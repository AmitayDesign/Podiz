import 'package:flutter/material.dart';
import 'package:podiz/src/features/discussion/presentation/comment/skeleton_comment_card.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/skeleton_podcast_avatar.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonGroupedComments extends StatelessWidget {
  const SkeletonGroupedComments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium!;
    final titleHeight = titleStyle.fontSize! * (titleStyle.height ?? 1);
    final subtitleStyle = context.textTheme.bodyMedium!;
    final subtitleHeight =
        subtitleStyle.fontSize! * (subtitleStyle.height ?? 1);

    return SkeletonItem(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16)
                  .add(const EdgeInsets.only(top: 8, bottom: 12)),
              child: Row(
                children: [
                  const SkeletonPodcastAvatar(size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                ],
              ),
            ),
            const SizedBox(height: 8),
            const SkeletonCommentCard(),
          ],
        ),
      ),
    );
  }
}
