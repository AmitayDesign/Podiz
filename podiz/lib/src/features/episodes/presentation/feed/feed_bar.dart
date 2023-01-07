import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/presentation/feed/feed_controller.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

class FeedBar extends ConsumerWidget with PreferredSizeWidget {
  const FeedBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(GradientBar.backgroundHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final title = ref.watch(feedControllerProvider);
    return GradientBar(
      title: Text(
        title,
        style: context.textTheme.bodyLarge,
      ),
      actions: [
        UserAvatarButton(user: user),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () => context.goNamed(AppRoute.settings.name),
        ),
      ],
    );
  }
}
