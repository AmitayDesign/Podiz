import 'package:flutter/material.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';

class ButtonPlay extends StatelessWidget {
  int time;
  ButtonPlay(this.time, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 23,
      decoration: BoxDecoration(
        color: Color(0xFF040404),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        const Icon(
          Icons.play_arrow,
          color: Color(0xE6FFFFFF),
          size: 20,
        ),
        Text(
          timePlayerFormatter(time),
          style: discussionCardPlay(),
        ),
      ]),
    );
  }
}
