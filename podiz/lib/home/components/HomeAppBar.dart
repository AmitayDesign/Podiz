import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';

class HomeAppBar extends StatelessWidget  {
  String title;
  HomeAppBar(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: kScreenWidth,
      decoration: BoxDecoration(
        gradient: appBarGradient(),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 56.0, left: 16),
        child: Text(title, style: podcastArtist()),
      ),
    );
  }

}
