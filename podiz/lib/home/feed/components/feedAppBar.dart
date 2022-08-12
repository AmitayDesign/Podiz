import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';
import 'package:podiz/home/components/profileAvatar.dart';
import 'package:podiz/providers.dart';

final homeBarTitleProvider = StateProvider<String>((ref) => 'lastListened');

class FeedAppBar extends ConsumerWidget with PreferredSizeWidget {
  const FeedAppBar({Key? key}) : super(key: key);

  static const height = 64.0;
  static const backgroundHeight = height * 1.25;

  @override
  Size get preferredSize => const Size.fromHeight(backgroundHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final title = ref.watch(homeBarTitleProvider);
    final backgroundColor = Theme.of(context).colorScheme.background;
    return AppBar(
      backgroundColor: Colors.transparent,
      toolbarHeight: height,
      title: Text(
        Locales.string(context, title),
        style: context.textTheme.bodyLarge!.copyWith(color: Palette.grey600),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        ProfileAvatar(user: user, radius: 16),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.grey),
          onPressed: () => context.goNamed(AppRoute.settings.name),
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: extendedAppBarGradient(backgroundColor),
        ),
        height: preferredSize.height + MediaQuery.of(context).padding.top,
      ),
    );
  }
}
