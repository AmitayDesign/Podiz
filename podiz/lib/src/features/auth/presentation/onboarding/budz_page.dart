import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/theme/context_theme.dart';

class BudzPage extends StatelessWidget {
  final VoidCallback? onSuccess;
  const BudzPage({Key? key, this.onSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
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
                      style: context.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Locales.string(context, "intro3_2"),
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        BudzImage('assets/icons/podiz.svg'),
                        BudzSign("+"),
                        BudzImage('assets/icons/spotify.svg'),
                        BudzSign("="),
                        BudzImage('assets/icons/heart.svg'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSuccess,
            child: const LocaleText('intro4'),
          ),
        ],
      ),
    );
  }
}

class BudzImage extends StatelessWidget {
  final String asset;
  const BudzImage(this.asset, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(asset, width: 48, height: 48, fit: BoxFit.contain);
  }
}

class BudzSign extends StatelessWidget {
  final String sign;
  const BudzSign(this.sign, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(sign, style: context.textTheme.headlineMedium),
    );
  }
}
