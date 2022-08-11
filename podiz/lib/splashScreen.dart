import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:podiz/aspect/extensions.dart';

enum SplashType { loading, error }

class SplashScreen extends StatelessWidget {
  final SplashType type;

  const SplashScreen._({Key? key, required this.type}) : super(key: key);
  factory SplashScreen() => const SplashScreen._(type: SplashType.loading);
  factory SplashScreen.error() => const SplashScreen._(type: SplashType.error);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backgroundImage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/brandIcon.png",
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text("Podiz", style: context.textTheme.headlineLarge),
            const SizedBox(height: 8),
            type == SplashType.loading
                ? SizedBox(
                    height: 24,
                    child: LoadingIndicator(
                      colors: [theme.primaryColor],
                      indicatorType: Indicator.ballBeat,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LocaleText(
                      'error1',
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
