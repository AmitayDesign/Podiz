import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/onboarding/components/podizAppBar.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/backgroundImage.png'),
                  fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 134,
                    ),
                    Text(Locales.string(context, "intro1_1"),
                        style: theme.textTheme.headline6),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(Locales.string(context, "intro1_2"),
                        style: theme.textTheme.headline5),
                    const SizedBox(
                      height: 100,
                    ),
                    Container(
                      width: 321,
                      height: 236,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('assets/images/onBoardingMen.png'),
                              fit: BoxFit.cover)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () =>
                          context.goNamed(AppRoute.connectBudz.name),
                      child: Text(
                        Locales.string(context, "intro2"),
                        style: theme.textTheme.button,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ]),
            ),
          ),
          const Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: PodizAppBar(),
          ),
        ],
      ),
    );
  }
}
