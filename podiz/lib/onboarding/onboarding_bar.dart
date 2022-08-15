import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/gradientAppBar.dart';

class OnboardingBar extends StatelessWidget with PreferredSizeWidget {
  const OnboardingBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(GradientAppBar.backgroundHeight);

  @override
  Widget build(BuildContext context) {
    return GradientAppBar(
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
    );
  }
}
