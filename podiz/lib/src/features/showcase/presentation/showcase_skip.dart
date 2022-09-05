import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
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
        child: Container(
          height: HomeScreen.bottomBarHeigh,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: ShowCaseWidget.of(context).dismiss,
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
                      'Next',
                      style: next == null
                          ? const TextStyle(color: Palette.pink)
                          : context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              Center(
                child: Text(
                  text,
                  style: context.textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
