import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podiz/aspect/theme/palette.dart';

/*
36 - 700 - white        displaySmall
32 - 700 - white        headlineLarge
24 - 600 - white        headlineSmall
20 - 700 - white        labelLarge
18 - 700 - white        titleLarge
16 - 700 - white        titleMedium
16 - 400 - white        bodyLarge
14 - 700 - white        titleSmall
14 - 400 - white70      bodyMedium
12 - 400 - grey600      bodySmall
*/

TextTheme textTheme(ColorScheme colorScheme) => GoogleFonts.montserratTextTheme(
      const TextTheme(
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: 1.2,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
          height: 1.2,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Palette.grey600,
          height: 1.2,
        ),
        labelLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
