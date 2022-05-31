import 'package:flutter/material.dart';

  final List<Color> colors = [
    const Color(0xFF230345),
    const Color(0xFF230345),
    const Color(0x7D230345),
    const Color(0x00230345)
  ];

LinearGradient appBarGradient() {
  return LinearGradient(colors: colors,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}