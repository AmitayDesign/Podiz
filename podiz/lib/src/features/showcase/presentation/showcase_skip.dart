import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

import 'package_files/showcase_widget.dart';
import 'showcase_keys.dart';

class ShowcaseSkip extends StatelessWidget {
  final int step;
  final bool top;
  final String text;
  final VoidCallback? next;

  const ShowcaseSkip({
    Key? key,
    required this.step,
    this.top = false,
    required this.text,
    required this.next,
  }) : super(key: key);

  bool get isLast => step == showcaseKeys.length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).padding,
      child: Material(
        color: Palette.pink,
        borderRadius: top
            ? const BorderRadius.vertical(
                bottom: Radius.circular(kBorderRadius),
              )
            : const BorderRadius.vertical(
                top: Radius.circular(kBorderRadius),
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8)
              .add(const EdgeInsets.only(bottom: 12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      ShowCaseWidget.of(context).dismiss();
                      ShowCaseWidget.of(context).widget.onFinish?.call();
                    },
                    child: Text(
                      'Skip',
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$step of ${showcaseKeys.length}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: next,
                    child: Text(
                      isLast ? 'Done' : 'Next',
                      style: next == null
                          ? const TextStyle(color: Palette.pink)
                          : context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  text,
                  style: context.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
