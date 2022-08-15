import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/src/theme/palette.dart';

class FollowShowButton extends ConsumerWidget {
  final String showUid;
  final String imageUrl;
  final bool isPlaying;

  const FollowShowButton(
    this.showUid, {
    Key? key,
    required this.imageUrl,
    required this.isPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthManager authManager = ref.watch(authManagerProvider);
    bool isFollowing = authManager.isFollowing(showUid);
    String follow = isFollowing ? "UNFOLLOW CAST" : "FOLLOW CAST";
    return FloatingActionButton.extended(
      icon: PodcastAvatar(imageUrl: imageUrl, size: 23),
      label: Text(
        follow,
        style: context.textTheme.titleMedium!.copyWith(
          color: Palette.white90,
        ),
      ),
      backgroundColor: const Color(0xFF7101EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      onPressed: () => isFollowing
          ? authManager.unfollowShow(showUid)
          : authManager.followShow(showUid),
    );
  }
}
