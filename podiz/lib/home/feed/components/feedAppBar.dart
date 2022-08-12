import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/gradientAppBar.dart';
import 'package:podiz/home/components/profileAvatar.dart';
import 'package:podiz/providers.dart';

final homeBarTitleProvider = StateProvider<String>((ref) => 'lastListened');

class FeedAppBar extends ConsumerWidget with PreferredSizeWidget {
  const FeedAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(GradientAppBar.backgroundHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final title = ref.watch(homeBarTitleProvider);
    return GradientAppBar(
      title: Text(
        Locales.string(context, title),
        style: context.textTheme.bodyLarge,
      ),
      actions: [
        ProfileAvatarButton(user: user, radius: 16),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.goNamed(AppRoute.settings.name),
        ),
      ],
    );
  }
}
