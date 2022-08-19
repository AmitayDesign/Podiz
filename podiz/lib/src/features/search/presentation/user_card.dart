import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

class UserCard extends ConsumerWidget {
  final UserPodiz user;
  final Widget? bottom;
  const UserCard(this.user, {Key? key, this.bottom}) : super(key: key);

  void openProfile(BuildContext context, Reader read, UserPodiz user) {
    context.goNamed(
      AppRoute.profile.name,
      params: {'userId': user.id},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = context.textTheme.titleMedium;
    final subtitleStyle = context.textTheme.bodyMedium;
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: InkWell(
        onTap: () => openProfile(context, ref.read, user),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              UserAvatar(user: user, radius: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.name,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text.rich(
                    TextSpan(
                      text: user.followers.length.toString(),
                      style: titleStyle,
                      children: [
                        TextSpan(text: ' Followers', style: subtitleStyle),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text.rich(
                    TextSpan(
                      text: user.following.length.toString(),
                      style: titleStyle,
                      children: [
                        TextSpan(text: ' Following', style: subtitleStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
