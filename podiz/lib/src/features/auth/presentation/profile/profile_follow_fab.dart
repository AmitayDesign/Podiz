import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';

class ProfileFollowFab extends ConsumerWidget {
  final UserPodiz user;
  const ProfileFollowFab(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowing = user.following.contains(user.id);

    return FloatingActionButton.extended(
      backgroundColor: context.colorScheme.primary,
      onPressed: () {},
      // => isFollowing
      //     ? podcastRepository.unfollow(user.id, userId)
      //     : podcastRepository.follow(user.id, userId),
      icon: UserAvatar(user: user, radius: 12),
      label: Text(
        isFollowing
            ? 'FOLLOWING ${user.name}'.hardcoded
            : 'FOLLOW ${user.name}'.hardcoded,
        style: context.textTheme.titleSmall,
      ),
    );
  }
}
