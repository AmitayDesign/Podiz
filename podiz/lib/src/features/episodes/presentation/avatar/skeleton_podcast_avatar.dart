import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonPodcastAvatar extends StatelessWidget {
  final double? size;
  const SkeletonPodcastAvatar({Key? key, this.size = 64}) : super(key: key);

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
