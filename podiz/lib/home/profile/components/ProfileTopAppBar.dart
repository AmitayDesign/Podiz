import 'package:flutter/material.dart';
import 'package:podiz/home/profile/components/followers.dart';
import 'package:podiz/home/profile/components/hashtagContainer.dart';
import 'package:podiz/home/profile/components/settingsButton.dart';
import 'package:podiz/objects/user/User.dart';


class ProfileTopAppBar extends StatelessWidget {
  final UserPodiz user;
  const ProfileTopAppBar(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: Column(children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              child: Icon(Icons.person_off_outlined),
            ),
            Spacer(),
            SettingsButton(),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            user.name,
            style: theme.textTheme.headline5,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: 12,
        ),
        HashtagContainerMock(),
        SizedBox(
          height: 20,
        ),
        Text(
          "Software Engineer\nI'd rather regret the things I've done then regret the things I haven't done - Lucille Ball",
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(
          height: 24,
        ),
        Followers(120, 96, 263),
      ]),
    );
  }
}
