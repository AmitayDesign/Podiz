import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/user/User.dart';

class FollowPeopleButton extends ConsumerWidget {
  final UserPodiz user;
  const FollowPeopleButton(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthManager authManager = ref.watch(authManagerProvider);
    bool isFollowing = authManager.isFollowing(user.uid);
    String follow =
        isFollowing ? "UNFOLLOW ${user.name}" : "FOLLOW ${user.name}";
    return FloatingActionButton.extended(
        icon: PodcastAvatar(imageUrl: user.image_url, size: 23),
        label: Text(follow, style: discussionCardPlay()),
        backgroundColor: const Color(0xFF7101EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () => isFollowing
            ? authManager.unfollowShow(user.uid)
            : authManager.followShow(user.uid));
  }
}
