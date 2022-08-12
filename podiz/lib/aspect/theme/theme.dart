import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/textTheme.dart';
import 'package:podiz/aspect/theme/themeConfig.dart';

ThemeData theme(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    backgroundColor: colorScheme.background,
    errorColor: colorScheme.error,
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.background,
    cardColor: colorScheme.surface,
    primaryTextTheme: textTheme(colorScheme),
    appBarTheme: _appBarTheme(colorScheme),
    bottomNavigationBarTheme: _bottomNavigationBarTheme(colorScheme),
    inputDecorationTheme: _inputDecorationTheme(colorScheme),
    elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
    textButtonTheme: _textButtonTheme(colorScheme),
    iconTheme: _iconTheme(colorScheme),
    dialogTheme: _dialogTheme(),
    checkboxTheme: _checkboxTheme(colorScheme),
    textTheme: textTheme(colorScheme).copyWith(
      subtitle1: textTheme(colorScheme).bodyMedium!.copyWith(
            color: Colors.white,
          ),
    ),
  );
}

CheckboxThemeData _checkboxTheme(ColorScheme colorScheme) => CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? colorScheme.primary
            : null,
      ),
    );

DialogTheme _dialogTheme() => DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
    );

IconThemeData _iconTheme(ColorScheme colorScheme) => IconThemeData(
      color: colorScheme.onBackground,
    );

InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) =>
    InputDecorationTheme(
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
      hintStyle: textTheme(colorScheme).bodyMedium,
    );

ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        onPrimary: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size.fromHeight(56),
        textStyle: textTheme(colorScheme).titleLarge,
      ),
    );

TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: textTheme(colorScheme).bodyMedium,
      ),
    );

AppBarTheme _appBarTheme(ColorScheme colorScheme) => AppBarTheme(
      systemOverlayStyle: ThemeConfig.overlayStyle(colorScheme.brightness),
      elevation: 0,
      backgroundColor: colorScheme.background,
      foregroundColor: colorScheme.onBackground,
    );

BottomNavigationBarThemeData _bottomNavigationBarTheme(
  ColorScheme colorScheme,
) =>
    BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: colorScheme.background.withOpacity(0.9),
      selectedItemColor: Palette.pink,
      unselectedItemColor: Colors.white70,
      selectedLabelStyle: textTheme(colorScheme).bodyMedium,
      unselectedLabelStyle: textTheme(colorScheme).bodyMedium,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
