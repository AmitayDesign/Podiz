import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/routing/app_router.dart';

class UserAvatar extends StatelessWidget {
  final UserPodiz user;
  final double radius;
  const UserAvatar({Key? key, required this.user, this.radius = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = user.imageUrl == null ? null : NetworkImage(user.imageUrl!);
    return CircleAvatar(
      radius: radius,
      backgroundImage: image, //TODO null image representation
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed(
            AppRoute.profile.name,
            params: {'userId': user.id},
          ),
        ),
      ),
    );
  }
}

class UserAvatarButton extends StatelessWidget {
  final UserPodiz user;
  final double radius;

  const UserAvatarButton({Key? key, required this.user, this.radius = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = user.imageUrl == null ? null : NetworkImage(user.imageUrl!);
    return IconButton(
      onPressed: () => context.pushNamed(
        AppRoute.profile.name,
        params: {'userId': user.id},
      ),
      icon: CircleAvatar(
        radius: radius,
        backgroundImage: image, //TODO null image representation
      ),
    );
  }
}
