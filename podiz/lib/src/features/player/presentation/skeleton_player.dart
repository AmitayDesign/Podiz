import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/episodes/avatar/skeleton_podcast_avatar.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonPlayer extends StatelessWidget {
  const SkeletonPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodyMedium!;
    final subtitleHeight =
        subtitleStyle.fontSize! * (subtitleStyle.height ?? 1);

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
            children: [
              const SkeletonLine(style: SkeletonLineStyle(height: 4)),
              Container(
                height: Player.height - 4,
                padding: const EdgeInsets.only(left: 24, right: 16),
                child: Row(
                  children: [
                    const SkeletonPodcastAvatar(size: 52),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                              width: 60,
                              height: 24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 7),
                          SkeletonLine(
                            style: SkeletonLineStyle(height: subtitleHeight),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    for (var i = 0; i < 3; i++)
                      const IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: null,
                        icon: SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            width: 24,
                            height: 24,
                            shape: BoxShape.circle,
                          ),
                        ),
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
