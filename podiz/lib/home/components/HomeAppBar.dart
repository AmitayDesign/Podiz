import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/providers.dart';

final homeBarTitleProvider = StateProvider<String>((ref) => 'lastListened');

class HomeAppBar extends ConsumerWidget with PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

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
        style: podcastArtist(),
      ),
      actions: [
        CircleProfile(user: user, size: 20),
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
