import 'package:flutter/material.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/profile/profilePage.dart';

class CircleProfile extends StatelessWidget {
  UserPodiz user;
  double size;
  CircleProfile({Key? key, required this.user, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundImage: NetworkImage(user.image_url),
      child: InkWell(
          onTap: () => Navigator.pushNamed(context, ProfilePage.route,
              arguments: user)),
    );
  }
}
