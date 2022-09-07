import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:podiz/src/theme/context_theme.dart';

enum SplashType { loading, error }

class SplashScreen extends StatelessWidget {
  final SplashType type;
  final VoidCallback? onRetry;

  const SplashScreen({Key? key})
      : type = SplashType.loading,
        onRetry = null,
        super(key: key);

  const SplashScreen.error({Key? key, this.onRetry})
      : type = SplashType.error,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colorScheme.background,
          image: const DecorationImage(
            image: AssetImage('assets/images/backgroundImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: type == SplashType.loading
            ? const SplashLoading()
            : SplashError(onRetry: onRetry),
      ),
    );
  }
}

class SplashLoading extends StatelessWidget {
  const SplashLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/lottie/loading_podiz.json',
          repeat: true,
          width: 72,
          height: 72,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text('Podiz', style: context.textTheme.headlineLarge),
      ],
    );
  }
}

class SplashError extends StatelessWidget {
  final VoidCallback? onRetry;
  const SplashError({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRetry != null) const Spacer(flex: 5),
        SvgPicture.asset(
          'assets/icons/podiz.svg',
          width: 72,
          height: 72,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text('Podiz', style: context.textTheme.headlineLarge),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: LocaleText(
            'error1',
            style: context.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onRetry,
            label: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
        if (onRetry != null) const Spacer(flex: 4),
      ],
    );
  }
}
