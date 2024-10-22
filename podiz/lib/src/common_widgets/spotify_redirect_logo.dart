import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:podiz/src/common_widgets/spotify_icon.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyRedirectLogo extends StatelessWidget {
  final String type;
  final String id;

  const SpotifyRedirectLogo({
    Key? key,
    required this.type,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 12,
      icon: const SpotifyIcon(),
      onPressed: () async {
        final episodeUrl = Uri.https('open.spotify.com', '/$type/$id');
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
