import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/user/User.dart';

class ProfileRow extends StatelessWidget {
  final UserPodiz user;
  const ProfileRow(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleProfile(user: user, size: 12.5),
        const SizedBox(width: 8),
        Text(user.name, style: context.textTheme.titleSmall),
        const SizedBox(width: 8),
        Text(
          "${user.followers.length.toString()} Followers",
          style: context.textTheme.bodySmall,
        )
      ],
    );
  }
}
