import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class IntroPage extends StatelessWidget {
  final VoidCallback? onSuccess;
  const IntroPage({Key? key, this.onSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Text(
            Locales.string(context, 'intro1_1'),
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            Locales.string(context, 'intro1_2'),
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/images/onBoardingMen.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSuccess,
            child: const LocaleText('intro2'),
          ),
        ],
      ),
    );
  }
}
