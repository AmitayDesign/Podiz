import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/profile/screens/settingsPage.dart';

class HomeAppBar extends ConsumerWidget {
  String title;
  HomeAppBar(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthManager authManager = ref.read(authManagerProvider);
    return Container(
      height: 96,
      width: kScreenWidth,
      decoration: BoxDecoration(
        gradient: appBarGradient(),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(Locales.string(context, title), style: podcastArtist()),
            const Spacer(),
            CircleProfile(user: authManager.userBloc!, size: 20),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.grey),
              onPressed: () => Navigator.pushNamed(context, SettingsPage.route),
            ),
          ],
        ),
      ),
    );
  }
}
