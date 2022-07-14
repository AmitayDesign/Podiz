import 'package:podiz/aspect/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:loading_indicator/loading_indicator.dart';

enum SplashType { loading, error }

class SplashScreen extends StatelessWidget {
  final SplashType type;

  SplashScreen() : type = SplashType.loading;
  SplashScreen.error() : type = SplashType.error;

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
            padding: EdgeInsets.only(bottom: 16),
            child: type == SplashType.error
                ? LocaleText(
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
