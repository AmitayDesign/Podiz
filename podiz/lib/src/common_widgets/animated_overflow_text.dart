import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AnimatedOverFlowText extends StatelessWidget {
  AnimatedOverFlowText({required this.text, this.style, Key? key})
      : super(key: key);

  String text;
  TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text,
      style: style,
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 120,
      velocity: 20,
      startAfter: const Duration(seconds: 2),
      pauseAfterRound: const Duration(seconds: 2),
      showFadingOnlyWhenScrolling: true,
      fadingEdgeStartFraction: 0.1,
      fadingEdgeEndFraction: 0.1,
      numberOfRounds: 50,
      startPadding: 0,
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
      textDirection: TextDirection.ltr,
    );
  }
}
