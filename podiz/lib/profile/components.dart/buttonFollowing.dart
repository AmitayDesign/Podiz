import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/theme/palette.dart';

class ButtonFollowing extends StatefulWidget {
  const ButtonFollowing({Key? key}) : super(key: key);

  @override
  State<ButtonFollowing> createState() => _ButtonFollowingState();
}

class _ButtonFollowingState extends State<ButtonFollowing> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 40,
      decoration: BoxDecoration(
          color: const Color(0xFFD74EFF),
          borderRadius: BorderRadius.circular(30)),
      child: Center(
        child: Text(
          "FOLLOWING JENIFER",
          style: context.textTheme.titleMedium!.copyWith(
            color: Palette.white90,
          ),
        ),
      ),
    );
  }
}
