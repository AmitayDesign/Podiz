import 'package:flutter/material.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/user/User.dart';

class ProfileRow extends StatelessWidget {
  UserPodiz user;
  ProfileRow(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleProfile(user: user, size: 12.5),
        const SizedBox(width: 8),
        Text(user.name, style: FFFFFFFF14700()),
        const SizedBox(width: 8),
        Text("${user.followers.length.toString()} Followers",
            style: discussionCardCommentHint())
      ],
    );
  }
}
