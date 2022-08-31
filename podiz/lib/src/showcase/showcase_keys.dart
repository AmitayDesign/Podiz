import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:showcaseview/showcaseview.dart';

final showcaseKeys = List.generate(2, (_) => GlobalKey());

class ShowcaseStep extends StatelessWidget {
  final int step;
  final VoidCallback? onTap;
  final String description;
  final Widget child;

  const ShowcaseStep({
    Key? key,
    required this.step,
    this.onTap,
    required this.description,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: showcaseKeys[step - 1],
      onTargetClick: onTap ?? ShowCaseWidget.of(context).next,
      disposeOnTap: false,
      description: description,
      descTextStyle: context.textTheme.bodyMedium,
      showcaseBackgroundColor: context.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      overlayOpacity: 0,
      child: child,
    );
  }
}

enum ShowcaseAlignment { top, bottom }

class ShowcaseOverlay extends StatelessWidget {
  final int step;
  final ShowcaseAlignment alignment;
  final String text;
  final Widget child;

  const ShowcaseOverlay({
    Key? key,
    required this.step,
    this.alignment = ShowcaseAlignment.bottom,
    required this.text,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeStep = ShowCaseWidget.of(context).activeWidgetId;
    if (activeStep != step - 1) return child;
    return Stack(
      alignment: alignment == ShowcaseAlignment.bottom
          ? Alignment.bottomCenter
          : Alignment.topCenter,
      children: [
        child,
        Padding(
          padding: MediaQuery.of(context).padding,
          child: Material(
            child: Container(
              height: HomeScreen.bottomBarHeigh,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Palette.pink,
                borderRadius: alignment == ShowcaseAlignment.bottom
                    ? const BorderRadius.vertical(
                        top: Radius.circular(kBorderRadius),
                      )
                    : const BorderRadius.vertical(
                        bottom: Radius.circular(kBorderRadius),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: ShowCaseWidget.of(context).dismiss, //!
                        child: const Text('Skip'),
                      ),
                      Expanded(
                        child: Text(
                          '$step of ${showcaseKeys.length}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Text(
                        'Skip',
                        style: TextStyle(color: Palette.pink),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        text,
                        style: context.textTheme.titleLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
