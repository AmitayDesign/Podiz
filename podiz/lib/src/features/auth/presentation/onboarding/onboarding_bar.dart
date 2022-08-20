import 'package:flutter/material.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/theme/context_theme.dart';

class OnboardingBar extends StatelessWidget with PreferredSizeWidget {
  const OnboardingBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(GradientBar.backgroundHeight);

  @override
  Widget build(BuildContext context) {
    return GradientBar(
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
