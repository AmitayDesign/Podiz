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
      color: theme.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: kScreenPadding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SvgPicture.asset(
          //   'assets/brand/logo.svg',
          //   width: 87,
          //   color: theme.primaryColor,
          // ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
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
          ),
        ],
      ),
    );
  }
}
