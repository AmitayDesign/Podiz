import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';

class PodizAppBar extends StatelessWidget {
  const PodizAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(gradient: appBarGradient()),
      height: 96,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
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
  Size get preferredSize => const Size.fromHeight(96);
}
