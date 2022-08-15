import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/home/components/profileAvatar.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';

class UserSearchTile extends StatelessWidget {
  final UserPodiz user;
  const UserSearchTile(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.goNamed(
        AppRoute.profile.name,
        params: {'userId': user.id},
      ),
      child: Container(
        height: 68,
        width: kScreenWidth - 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            ProfileAvatar(user: user, radius: 20),
            const SizedBox(width: 11),
            LimitedBox(
              maxWidth: kScreenWidth - (16 + 16 + 20 + 11 + 40 + 16 + 16),
              child: Text(
                user.name,
                style: context.textTheme.titleLarge,
              ),
            ),
            const Spacer(),
            Column(children: [
              const Spacer(),
              Row(children: [
                Text(
                  user.followers.length.toString(),
                  style: context.textTheme.titleLarge!.copyWith(
                    color: Palette.white90,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Followers",
                  style: context.textTheme.bodyLarge!.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Text(
                  user.following.length.toString(),
                  style: context.textTheme.titleLarge!.copyWith(
                    color: Palette.white90,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Following",
                  style: context.textTheme.bodyLarge!.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ]),
              const Spacer(),
            ]),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
