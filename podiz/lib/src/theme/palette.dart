import 'package:flutter/material.dart';

abstract class Palette {
  static const Color purple = Color(0xFF7101EE);
  static const Color darkPurple = Color(0xFF3E0979);
  static const Color pink = Color(0xFFD74EFF);
  static const Color lightPink = Color(0xFFE5CEFF);
  static const Color red = Color(0xFF8F1010);
  static const Color white90 = Color(0xE5FFFFFF);
  static const Color grey600 = Color(0xFF9E9E9E);
  static const Color grey800 = Color(0xFF4E4E4E);
  static const Color grey900 = Color(0xFF404040);
  static const Color green = Color(0xFF1DB954); // spotify color

  static const ColorScheme colorScheme = ColorScheme.dark(
    primary: purple,
    secondary: pink,
    surface: Color(0xFF262626),
    background: Color(0xFF090909),
    error: red,

    onPrimary: Color(0xFF090909),
    // onSecondary: Colors.white,
    onSurface: Color(0xFF8D8D91),
    onBackground: Color(0xFFFDFDFD),
    onError: Colors.white,
  );
}
