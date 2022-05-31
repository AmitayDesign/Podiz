import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/widgets/asyncElevatedButton.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/onboarding/components/PodizAppBar.dart';
import 'package:podiz/onboarding/components/spotifyContainer.dart';


class ConnectBudzPage extends StatelessWidget {
  const ConnectBudzPage({Key? key}) : super(key: key);
  static const route = '/connectBudz';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: const PodizAppBar(),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgroundImage.png'),
                fit: BoxFit.cover),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Spacer(),
              const SpotifyContainer(),
              const Spacer(),
              AsyncElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, HomePage.route),
                child: Text(Locales.string(context, "intro4"), style: theme.textTheme.button,),
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
          ),
        ));
  }
}
