import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/objects/user/User.dart';

class ProfileAvatar extends StatelessWidget {
  final UserPodiz user;
  final double radius;
  const ProfileAvatar({Key? key, required this.user, required this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoute.profile.name,
        params: {'userId': user.uid},
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.image_url),
      ),
    );
  }
}

class ProfileAvatarButton extends StatelessWidget {
  final UserPodiz user;
  final double radius;

  const ProfileAvatarButton({
    Key? key,
    required this.user,
    required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.pushNamed(
        AppRoute.profile.name,
        params: {'userId': user.uid},
      ),
      icon: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.image_url),
      ),
    );
  }
}
