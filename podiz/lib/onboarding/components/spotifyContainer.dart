import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';

class SpotifyContainer extends StatelessWidget {
  const SpotifyContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 360,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Locales.string(context, "intro3_1_1"),
            style: theme.textTheme.bodyText1,
          ),
          Text(
            Locales.string(context, "intro3_1_2"),
            style: theme.textTheme.bodyText1,
          ),
          Text(
            Locales.string(context, "intro3_1_3"),
            style: theme.textTheme.bodyText1,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            Locales.string(context, "intro3_2_1"),
            style: theme.textTheme.bodyText2,
          ),
          Text(
            Locales.string(context, "intro3_2_2"),
            style: theme.textTheme.bodyText2,
          ),
          const SizedBox(
            height: 36,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/images/brandIcon.png"),
                  fit: BoxFit.cover,
                )),
              ),
              const SizedBox(width: 15),
              Text(
                "+",
                style: iconStyle(),
              ),
              const SizedBox(width: 15),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/images/spotifyLogo.png"),
                  fit: BoxFit.cover,
                )),
              ),
              const SizedBox(width: 15),
              Text(
                "=",
                style: iconStyle(),
              ),
              const SizedBox(width: 15),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/images/heart.png"),
                  fit: BoxFit.cover,
                )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
