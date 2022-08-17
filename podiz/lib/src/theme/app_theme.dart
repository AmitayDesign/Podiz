import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';

import 'app_text_theme.dart';
import 'palette.dart';

final themeProvider = Provider<ThemeData>((ref) {
  const colorScheme = Palette.colorScheme;
  final textTheme = appTextTheme(colorScheme);
  return ThemeData(
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    backgroundColor: colorScheme.background,
    errorColor: colorScheme.error,
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.background,
    cardColor: colorScheme.surface,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: colorScheme.background,
      foregroundColor: colorScheme.onBackground,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: colorScheme.background.withOpacity(0.9),
      selectedItemColor: Palette.pink,
      unselectedItemColor: Colors.white70,
      selectedLabelStyle: textTheme.bodyMedium,
      unselectedLabelStyle: textTheme.bodyMedium,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.grey900,
      iconColor: Colors.white70,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(30),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      hintStyle: textTheme.bodyMedium,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: textTheme.bodyMedium,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        onPrimary: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size.fromHeight(56),
        textStyle: textTheme.titleMedium,
      ),
    ),
    iconTheme: IconThemeData(
      color: colorScheme.onBackground,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? colorScheme.primary
            : null,
      ),
    ),
    dividerTheme: const DividerThemeData(
        color: Palette.grey800,
        thickness: 1,
        indent: 0,
        endIndent: 0,
        space: 1),
  );
});
