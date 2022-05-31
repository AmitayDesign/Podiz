import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';

class PodizAppBar extends StatelessWidget with PreferredSizeWidget {
  const PodizAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: appBarGradient()),
      ),
      title: Container(
        height: 96,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/images/brandIcon.png"),
                  fit: BoxFit.cover,
                )),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                "Podiz",
                style: podizStyle(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(kScreenWidth, 96);
}
