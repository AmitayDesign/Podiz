import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/skeleton_episode_content.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonDiscussionHeader extends ConsumerWidget {
  const SkeletonDiscussionHeader({Key? key}) : super(key: key);

  final backgroundColor = Palette.darkPurple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Palette.darkPurple,
      child: SkeletonTheme(
        shimmerGradient: LinearGradient(colors: [
          Color.alphaBlend(
            Palette.purple.withOpacity(0.5),
            Palette.darkPurple,
          ),
          Palette.purple,
          Color.alphaBlend(
            Palette.purple.withOpacity(0.5),
            Palette.darkPurple,
          ),
        ]),
        themeMode: ThemeMode.light,
        child: SkeletonItem(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SkeletonEpisodeContent(),
              SkeletonLine(style: SkeletonLineStyle(height: 4)),
            ],
          ),
        ),
      ),
    );
  }
}
