import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:lottie/lottie.dart';
import 'package:podiz/src/theme/context_theme.dart';

enum SplashType { loading, error }

class SplashScreen extends StatelessWidget {
  final SplashType type;

  const SplashScreen({Key? key})
      : type = SplashType.loading,
        super(key: key);

  const SplashScreen.error({Key? key})
      : type = SplashType.error,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colorScheme.background,
          image: const DecorationImage(
            image: AssetImage("assets/images/backgroundImage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == SplashType.loading)
              Lottie.asset(
                'assets/lottie/loading_podiz.json',
                repeat: true,
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              )
            else if (type == SplashType.error)
              Image.asset(
                "assets/images/brandIcon.png",
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 8),
            Text("Podiz", style: context.textTheme.headlineLarge),
            if (type == SplashType.error) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LocaleText(
                  'error1',
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
