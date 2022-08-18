import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/routing/app_router.dart';

import 'feed_controller.dart';

class FeedBar extends ConsumerWidget with PreferredSizeWidget {
  const FeedBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(GradientBar.backgroundHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentuserFutureProvider);
    final title = ref.watch(feedControllerProvider);
    return GradientBar(
      title: Text(
        Locales.string(context, title),
        style: context.textTheme.bodyLarge,
      ),
      actions: [
        UserAvatarButton(user: user),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.goNamed(AppRoute.settings.name),
        ),
      ],
    );
  }
}
