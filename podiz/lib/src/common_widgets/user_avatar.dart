import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/routing/app_router.dart';

class UserAvatar extends StatelessWidget {
  final UserPodiz user;
  final double radius;
  final bool enableNavigation;

  const UserAvatar({
    Key? key,
    required this.user,
    this.radius = 16,
    this.enableNavigation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImageProvider image = user.imageUrl == null
        ? const AssetImage('assets/images/loadingImage.png') as ImageProvider
        : NetworkImage(user.imageUrl!);

    return CircleAvatar(
      radius: radius,
      backgroundImage: image,
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: InkWell(
          onTap: enableNavigation
              ? () => context.pushNamed(
                    AppRoute.profile.name,
                    params: {'userId': user.id},
                  )
              : null,
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
    final ImageProvider image = user.imageUrl == null
        ? const AssetImage('assets/images/loadingImage.png') as ImageProvider
        : NetworkImage(user.imageUrl!);

    return IconButton(
      onPressed: () => context.pushNamed(
        AppRoute.profile.name,
        params: {'userId': user.id},
      ),
      icon: CircleAvatar(
        radius: radius,
        backgroundImage: image,
      ),
    );
  }
}
