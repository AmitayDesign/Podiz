import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/showcase/presentation/package_files/showcase_widget.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_step.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';

class ProfileFollowFab extends ConsumerWidget {
  final UserPodiz user;
  const ProfileFollowFab(this.user, {Key? key}) : super(key: key);

  void follow(Reader read, UserPodiz currentUser, bool isFollowing) {
    final userRepository = read(userRepositoryProvider);
    isFollowing
        ? userRepository.unfollow(currentUser.id, user.id)
        : userRepository.follow(currentUser.id, user.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isFollowing = currentUser.following.contains(user.id);

    return ShowcaseStep(
      step: 4,
      skipOnTop: true,
      shapeBorder: const CircleBorder(),
      onTap: () {
        follow(ref.read, user, isFollowing);
        ShowCaseWidget.of(context).next();
      },
      title: 'Follow people to see what they are talking about',
      description: 'Just hit follow  ',
      child: FloatingActionButton.extended(
        backgroundColor: context.colorScheme.primary,
        onPressed: () => follow(ref.read, currentUser, isFollowing),
        icon: UserAvatar(user: user, radius: 12),
        label: Text(
          isFollowing
              ? 'FOLLOWING ${user.name}'.hardcoded
              : 'FOLLOW ${user.name}'.hardcoded,
          style: context.textTheme.titleSmall,
        ),
      ),
    );
  }
}
