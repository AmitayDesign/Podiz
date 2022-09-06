import 'package:flutter/material.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_skip.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'package_files/showcase.dart';
import 'package_files/showcase_widget.dart';
import 'showcase_keys.dart';

class ShowcaseStep extends StatelessWidget {
  final int step;
  final VoidCallback? onTap;
  final VoidCallback? onNext;
  final String title;
  final String description;
  final bool skipOnTop;
  final Widget child;

  const ShowcaseStep({
    Key? key,
    required this.step,
    this.onTap,
    this.onNext,
    required this.title,
    required this.description,
    this.skipOnTop = false,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final skip = ShowcaseSkip(
      step: step,
      text: title,
      next: () {
        onNext?.call();
        ShowCaseWidget.of(context).next();
      },
      top: skipOnTop,
    );
    return Showcase(
      globalKey: showcaseKeys[step - 1],
      onTargetClick: onTap,
      disposeOnTap: false,
      description: description,
      descTextStyle: context.textTheme.bodyMedium,
      showcaseBackgroundColor: context.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      // overlayOpacity: 0,
      leading: skipOnTop ? skip : null,
      trailing: skipOnTop ? null : skip,
      child: child,
    );
  }
}
