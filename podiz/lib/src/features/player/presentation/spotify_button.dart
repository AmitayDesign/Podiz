import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/spotify_icon.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:url_launcher/url_launcher.dart';

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
          SpotifyIcon(color: context.colorScheme.onPrimary),
          const SizedBox(width: 12),
          Text(
            "OPEN SPOTIFY".hardcoded,
            style: context.textTheme.titleSmall!.copyWith(
              color: context.colorScheme.onPrimary,
            ),
            // maxLines: 1,
          )
        ],
      ),
      onPressed: () async {
        final episodeUrl = Uri.https('open.spotify.com', '/episode/$episodeId');
        if (Platform.isIOS) {
          await LaunchApp.openApp(
            androidPackageName: 'com.spotify.music',
            iosUrlScheme: episodeUrl.toString(),
          );
        }
        launchUrl(episodeUrl, mode: LaunchMode.externalApplication);
      },
    );
  }
}
