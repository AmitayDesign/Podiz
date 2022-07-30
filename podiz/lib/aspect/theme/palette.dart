import 'package:flutter/material.dart';

class Palette {
  static const Color purple = Color(0xFF6310BF);
  static const Color darkPurple = Color(0xFF7101EE);
  static const Color blue = Color(0xFF2C13B9);
  static const Color red = Color(0xFFE45858);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color grey900 = Color(0xFF404040);

  static const ColorScheme colorScheme = ColorScheme.dark(
    primary: purple,
    secondary: blue,
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
