import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/widgets/asyncElevatedButton.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/onboarding/components/podizAppBar.dart';
import 'package:podiz/onboarding/components/spotifyContainer.dart';

class ConnectBudzPage extends StatelessWidget {
  const ConnectBudzPage({Key? key}) : super(key: key);
  static const route = '/connectBudz';
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
                  const SizedBox(height: 96),
                  const Spacer(),
                  const SpotifyContainer(),
                  const Spacer(),
                  AsyncElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, HomePage.route),
                    child: Text(
                      Locales.string(context, "intro4"),
                      style: theme.textTheme.button,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
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
