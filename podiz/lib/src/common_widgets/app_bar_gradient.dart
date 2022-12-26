import 'package:flutter/material.dart';

const List<Color> colors = [
  Color(0xFF230345),
  Color(0xFF230345),
  Color(0x7D230345),
  Color(0x00230345)
];

LinearGradient appBarGradient() {
  return const LinearGradient(
    colors: colors,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // stops: [0, 0.33, 0.66, 1],
  );
}

LinearGradient extendedAppBarGradient(Color backgroundColor) {
  return LinearGradient(
    colors: [
      colors[0],
      colors[1],
      Color.alphaBlend(colors[2], backgroundColor),
      Color.alphaBlend(colors[3], backgroundColor),
      Color.alphaBlend(colors[3], backgroundColor).withOpacity(0),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // stops: [0, 0.25, 0.5, 0.75, 1],
  );
}
