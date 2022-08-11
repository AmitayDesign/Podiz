import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';

class OnboardingAppBar extends StatelessWidget with PreferredSizeWidget {
  const OnboardingAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/brandIcon.png',
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text('Podiz', style: context.textTheme.headlineLarge)
        ],
      ),
      flexibleSpace: Container(
        height: preferredSize.height + MediaQuery.of(context).padding.top,
        decoration: BoxDecoration(gradient: appBarGradient()),
      ),
    );
  }
}
