import 'package:flutter/material.dart';
import 'package:podiz/home/feed/screens/commentPage.dart';
import 'package:podiz/player/screens/discussionPage.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/notifications/NotificationsPage.dart';
import 'package:podiz/home/search/screens/showPage.dart';
import 'package:podiz/onboarding/connectBudz.dart';
import 'package:podiz/onboarding/onbordingPage.dart';
import 'package:podiz/onboarding/screens/spotifyView.dart';
import 'package:podiz/profile/profilePage.dart';
import 'package:podiz/profile/screens/settingsPage.dart';

class RouterConfig {
  static dynamic _args(BuildContext context) =>
      ModalRoute.of(context)?.settings.arguments!;

  static Map<String, WidgetBuilder> routes = {
    HomePage.route: (context) => HomePage(_args(context)),
    OnBoardingPage.route: (_) => const OnBoardingPage(),
    ConnectBudzPage.route: (_) => const ConnectBudzPage(),
    DiscussionPage.route: (_) => DiscussionPage(),
    ProfilePage.route: (context) => ProfilePage(_args(context)),
    SpotifyView.route: (_) => SpotifyView(),
    SettingsPage.route: (_) => SettingsPage(),
    ShowPage.route: (context) => ShowPage(_args(context)),
    CommentPage.route: (context) => CommentPage(_args(context)),

    // OrderPage.route: (context) => OrderPage(_args(context)),
  };
}
