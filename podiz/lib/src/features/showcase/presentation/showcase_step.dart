import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_controller.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_skip.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'package_files/showcase.dart';
import 'package_files/showcase_widget.dart';
import 'showcase_keys.dart';

class ShowcaseStep extends ConsumerWidget {
  final int step;
  final VoidCallback? onTap;
  final VoidCallback? onNext;
  final String title;
  final String description;
  final bool skipOnTop;
  final ShapeBorder? shapeBorder;
  final Widget child;

  const ShowcaseStep({
    Key? key,
    required this.step,
    this.onTap,
    this.onNext,
    required this.title,
    required this.description,
    this.skipOnTop = false,
    this.shapeBorder,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShowcasing = ref.watch(showcaseRunningProvider);
    if (!isShowcasing) return child;
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
      shapeBorder: shapeBorder,
      leading: skipOnTop ? skip : null,
      trailing: skipOnTop ? null : skip,
      child: child,
    );
  }
}
