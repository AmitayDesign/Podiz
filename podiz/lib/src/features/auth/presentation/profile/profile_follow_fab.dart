import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';

class ProfileFollowFab extends ConsumerWidget {
  final UserPodiz user;
  const ProfileFollowFab(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isFollowing = currentUser.following.contains(user.id);

    return FloatingActionButton.extended(
      backgroundColor: context.colorScheme.primary,
      onPressed: () {
        final userRepository = ref.read(userRepositoryProvider);
        isFollowing
            ? userRepository.unfollow(currentUser.id, user.id)
            : userRepository.follow(currentUser.id, user.id);
      },
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
