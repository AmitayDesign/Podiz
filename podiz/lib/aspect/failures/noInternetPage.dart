import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/src/theme/context_theme.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(gradient: gradient()),
          child: Column(
            children: [
              //backButton
              Image.asset("assets/images/noInternetImage.png"),
              const SizedBox(height: 32),
              Text(Locales.string(context, "nointernet_1"),
                  style: context.textTheme.displaySmall),
              const SizedBox(height: 32),
              Text(Locales.string(context, "nointernet_2"),
                  style: context.textTheme.bodyLarge),
            ],
          )),
    );
  }

  LinearGradient gradient() {
    return const LinearGradient(colors: [
      Color(0xFF20053E),
      Color(0xFF210640),
      Color(0x7F190232),
      Color(0x000D011A),
    ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  }
}
