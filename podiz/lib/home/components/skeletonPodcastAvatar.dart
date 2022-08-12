import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonPodcastAvatar extends StatelessWidget {
  final double size;
  const SkeletonPodcastAvatar({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonAvatar(
      style: SkeletonAvatarStyle(
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
    );
  }
}
