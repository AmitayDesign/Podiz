import 'package:flutter/material.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/profile/ProfilePage.dart';
import 'package:podiz/home/profile/screens/editProfilePage.dart';
import 'package:podiz/onboarding/connectBudz.dart';
import 'package:podiz/onboarding/onbordingPage.dart';


class RouterConfig {
  static dynamic _args(BuildContext context) =>
      ModalRoute.of(context)!.settings.arguments!;

  static Map<String, WidgetBuilder> routes = {
    HomePage.route: (_) => HomePage(),
    OnBoardingPage.route: (_) => OnBoardingPage(),
    ConnectBudzPage.route: (_) => ConnectBudzPage(),
    ProfilePage.route: (_) => ProfilePage(),
    EditProfilePage.route: (_) => EditProfilePage(),
   
    // OrderPage.route: (context) => OrderPage(_args(context)),
  
  
  };
}
