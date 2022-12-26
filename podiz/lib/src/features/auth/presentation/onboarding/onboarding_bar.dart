import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          SvgPicture.asset(
            'assets/icons/podiz.svg',
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
