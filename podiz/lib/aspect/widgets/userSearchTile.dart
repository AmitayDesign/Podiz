import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/profile/profilePage.dart';

class UserSeachTile extends StatelessWidget {
  UserPodiz user;
  UserSeachTile(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, ProfilePage.route, arguments: user),
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
            Spacer(),
            Column(children: [
              Spacer(),
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
              Spacer(),
            ]),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
