import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:podiz/aspect/constants.dart';

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
    print("Building SpalshScreen");
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/backgroundImage.png"),
            fit: BoxFit.cover),
      ),
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/brandIcon.png", width: 70, height: 70),
          const SizedBox(height: 8),
          Text(
            "Podiz",
            style: theme.textTheme.headline5,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 16),
            child: type == SplashType.error
                ? const LocaleText(
                    'error1',
                    textAlign: TextAlign.center,
                  )
                : SizedBox(
                    height: 24,
                    child: LoadingIndicator(
                      colors: [theme.primaryColor],
                      indicatorType: Indicator.ballBeat,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
