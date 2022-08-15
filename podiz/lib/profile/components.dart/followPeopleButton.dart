import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/theme/palette.dart';

class followPeopleButton extends ConsumerWidget {
  final UserPodiz user;
  const followPeopleButton(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthManager authManager = ref.watch(authManagerProvider);
    bool isFollowing = authManager.isFollowing(user.id);
    String follow =
        isFollowing ? "UNFOLLOW ${user.name}" : "FOLLOW ${user.name}";
    return FloatingActionButton.extended(
      icon: PodcastAvatar(imageUrl: user.imageUrl, size: 23),
      label: Text(
        follow,
        style: context.textTheme.titleMedium!.copyWith(
          color: Palette.white90,
        ),
      ),
      backgroundColor: const Color(0xFF7101EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      onPressed: () => isFollowing
          ? authManager.unfollowShow(user.id)
          : authManager.followShow(user.id),
    );
  }
}
