import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
36 - 700 - white        displaySmall
32 - 700 - white        headlineLarge
24 - 600 - white        headlineSmall
18 - 700 - white        titleLarge
16 - 700 - white        titleMedium
16 - 400 - white        bodyLarge
14 - 700 - white        titleSmall
14 - 400 - white70      bodyMedium
12 - 400 - grey600      bodySmall
*/

TextTheme appTextTheme(ColorScheme colorScheme) =>
    GoogleFonts.montserratTextTheme(
      const TextTheme(
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ),
    );
