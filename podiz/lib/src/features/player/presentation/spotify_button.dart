import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

class SpotifyButton extends ConsumerWidget {
  const SpotifyButton(this.episodeId, {Key? key}) : super(key: key);
  final String episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 88.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          backgroundColor: Palette.spotifyGreen,
          foregroundColor: context.colorScheme.background,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(
            "assets/icons/spotify.svg",
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            color: context.colorScheme.background,
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            "OPEN SPOTIFY".hardcoded,
            style: context.textTheme.titleSmall!
                .copyWith(color: context.colorScheme.background),
          )
        ]),
        onPressed: () async {
          await LaunchApp.openApp(
              androidPackageName: 'com.spotify.music',
              iosUrlScheme: 'spotify:/'); //TODO add link to playStore
        },
      ),
    );
  }
}
