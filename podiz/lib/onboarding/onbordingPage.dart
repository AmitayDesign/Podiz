import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/widgets/asyncElevatedButton.dart';
import 'package:podiz/onboarding/components/PodizAppBar.dart';
import 'package:podiz/onboarding/connectBudz.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);
  static const route = '/onBoarding';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: PodizAppBar(),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgroundImage.png'),
                fit: BoxFit.cover),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: [
              const SizedBox(
                height: 38,
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
                        image: AssetImage('assets/images/onBoardingMen.png'),
                        fit: BoxFit.cover)),
              ),
              const Spacer(),
              AsyncElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, ConnectBudzPage.route),
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
        ));
  }
}
