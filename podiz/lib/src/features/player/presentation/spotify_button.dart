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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: Palette.spotifyGreen,
        foregroundColor: context.colorScheme.background,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/icons/spotify.svg",
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            color: context.colorScheme.background,
          ),
          const SizedBox(width: 12),
          Text(
            "OPEN SPOTIFY".hardcoded,
            style: context.textTheme.titleSmall!
                .copyWith(color: context.colorScheme.background),
            // maxLines: 1,
          )
        ],
      ),
      onPressed: () async {
        await LaunchApp.openApp(
          androidPackageName: 'com.spotify.music',
          iosUrlScheme: 'spotify:/',
        ); //TODO add link to playStore
      },
    );
  }
}
