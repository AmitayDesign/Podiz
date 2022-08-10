import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/objects/user/User.dart';

class CircleProfile extends StatelessWidget {
  final UserPodiz user;
  final double size;
  const CircleProfile({Key? key, required this.user, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundImage: NetworkImage(user.image_url),
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.profile.name,
          params: {'userId': user.uid},
        ),
      ),
    );
  }
}
