import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/providers.dart';

final homeBarTitleProvider = StateProvider<String>((ref) => 'lastListened');

class HomeAppBar extends ConsumerWidget with PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final title = ref.watch(homeBarTitleProvider);
    return AppBar(
      toolbarHeight: preferredSize.height,
      title: Text(
        Locales.string(context, title),
        style: context.textTheme.bodyLarge!.copyWith(color: Palette.grey600),
      ),
      actions: [
        CircleProfile(user: user, size: 20),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.grey),
          onPressed: () => context.goNamed(AppRoute.settings.name),
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: appBarGradient()),
        height: preferredSize.height + MediaQuery.of(context).padding.top,
      ),
    );
  }
}
