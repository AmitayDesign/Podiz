import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/episodes/presentation/card/skeleton_episode_content.dart';
import 'package:podiz/src/theme/context_theme.dart';

class SkeletonEpisodeCard extends StatelessWidget {
  final double? bottomHeight;
  const SkeletonEpisodeCard({Key? key, this.bottomHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.theme.cardColor.withOpacity(0.5),
      margin: const EdgeInsets.all(8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: const SkeletonEpisodeContent(),
    );
  }
}
