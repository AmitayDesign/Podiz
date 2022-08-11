import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/providers.dart';

class HomeAppBar extends ConsumerWidget {
  final String title;
  const HomeAppBar(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return AppBar(
      flexibleSpace: Container(
        height: 96,
        width: kScreenWidth,
        decoration: BoxDecoration(
          gradient: appBarGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(Locales.string(context, title), style: podcastArtist()),
              const Spacer(),
              CircleProfile(user: user, size: 20),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey),
                onPressed: () => context.goNamed(AppRoute.settings.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
