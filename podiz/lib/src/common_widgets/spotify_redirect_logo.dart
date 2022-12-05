import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpotifyRedirectLogo extends StatelessWidget {
  SpotifyRedirectLogo({required this.id, required this.type, Key? key})
      : super(key: key);

  String type;
  String id;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 12,
        icon: SvgPicture.asset("assets/icons/spotify.svg"),
        onPressed: () async {
          await LaunchApp.openApp(
            androidPackageName: 'com.spotify.music',
            iosUrlScheme: 'https://open.spotify.com/$type/$id',
          ); //TODO add link to playStore
        });
  }
}
