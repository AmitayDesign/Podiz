import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/home/profile/screens/editProfilePage.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(kBorderRadius),
      onTap: () => Navigator.pushNamed(context, EditProfilePage.route),
      child: Container(
        width: 190,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, color: Colors.white,),//TODO Change color
            SizedBox(width: 5,),
            Text(Locales.string(context, "settings"))//TODO give style
          ],
        ),
        decoration: BoxDecoration(
          color: Color.fromARGB(46, 255, 255, 255), //TODO change this color
          borderRadius: BorderRadius.circular(30)
        ),
      ),
    );
  }
}
