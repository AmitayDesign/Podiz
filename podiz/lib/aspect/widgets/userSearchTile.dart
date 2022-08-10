import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/user/User.dart';

class UserSearchTile extends StatelessWidget {
  final UserPodiz user;
  const UserSearchTile(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.goNamed(
        AppRoute.profile.name,
        params: {'userId': user.uid},
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
            CircleProfile(user: user, size: 20),
            const SizedBox(width: 11),
            LimitedBox(
                maxWidth: kScreenWidth - (16 + 16 + 20 + 11 + 40 + 16 + 16),
                child: Text(user.name, style: followerName())),
            const Spacer(),
            Column(children: [
              const Spacer(),
              Row(children: [
                Text(
                  user.followers.length.toString(),
                  style: followersNumber(),
                ),
                const SizedBox(width: 4),
                Text(
                  "Followers",
                  style: followersText(),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Text(
                  user.following.length.toString(),
                  style: followersNumber(),
                ),
                const SizedBox(width: 4),
                Text(
                  "Following",
                  style: followersText(),
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
