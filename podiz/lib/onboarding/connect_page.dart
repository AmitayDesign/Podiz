import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';

class ConnectPage extends ConsumerWidget {
  const ConnectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: context.colorScheme.background,
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Locales.string(context, "intro3_1"),
              style: context.textTheme.labelLarge!.copyWith(
                color: Colors.grey.shade100,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              Locales.string(context, "intro3_2"),
              style: context.textTheme.titleSmall!.copyWith(
                color: Colors.grey.shade100,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ConnectImage('assets/images/brandIcon.png'),
                ConnectSign("+"),
                ConnectImage('assets/images/spotifyLogo.png'),
                ConnectSign("="),
                ConnectImage('assets/images/heart.png'),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ConnectImage extends StatelessWidget {
  final String asset;
  const ConnectImage(this.asset, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, width: 48, height: 48, fit: BoxFit.contain);
  }
}

class ConnectSign extends StatelessWidget {
  final String sign;
  const ConnectSign(this.sign, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(sign, style: context.textTheme.headlineLarge),
    );
  }
}
