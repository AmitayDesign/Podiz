import 'package:flutter/material.dart';
import 'package:podiz/home/feed/screens/discussionPage.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/notifications/NotificationsPage.dart';
import 'package:podiz/home/notifications/screens/editProfilePage.dart';
import 'package:podiz/onboarding/connectBudz.dart';
import 'package:podiz/onboarding/onbordingPage.dart';
import 'package:podiz/profile/followerProfilePage.dart';


class RouterConfig {
  static dynamic _args(BuildContext context) =>
      ModalRoute.of(context)!.settings.arguments!;

  static Map<String, WidgetBuilder> routes = {
    HomePage.route: (_) => HomePage(),
    OnBoardingPage.route: (_) => const OnBoardingPage(),
    ConnectBudzPage.route: (_) => const ConnectBudzPage(),
    NotificationsPage.route: (_) => NotificationsPage(),
    EditProfilePage.route: (_) => EditProfilePage(),
    DiscussionPage.route: (_) => DiscussionPage(),
    FollowerProfilePage.route: (_) => FollowerProfilePage(),
   
    // OrderPage.route: (context) => OrderPage(_args(context)),
  
  
  };
}
