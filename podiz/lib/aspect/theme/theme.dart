import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/themeConfig.dart';
import 'package:flutter/material.dart';

ThemeData theme(ColorScheme colorScheme) => ThemeData(
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      backgroundColor: colorScheme.background,
      errorColor: colorScheme.error,
      scaffoldBackgroundColor: colorScheme.background,
      canvasColor: colorScheme.background,
      fontFamily: 'Montserrat', //TODO install Montserrat and the other
      primaryTextTheme: _textTheme(colorScheme),
      textTheme: _textTheme(colorScheme),
      appBarTheme: _appBarTheme(colorScheme),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(),
      iconTheme: _iconTheme(colorScheme),
      dialogTheme: _dialogTheme(),
      checkboxTheme: _checkboxTheme(colorScheme),
    );

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
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: (kButtonHeight - 14) / 2,
      ),
      hintStyle: TextStyle(color: colorScheme.onSurface),
      iconColor: colorScheme.onSurface,
    );

ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24),
        minimumSize: Size.fromHeight(kButtonHeight),
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
      backgroundColor: colorScheme.background,
      selectedItemColor: colorScheme.onBackground,
      unselectedItemColor: colorScheme.onSurface,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );

TextTheme _textTheme(ColorScheme colorScheme) => TextTheme(
      headline5: TextStyle(
        // fontFamily: 'Poppins',
        color: colorScheme.onBackground,
        fontSize: 40,
        height: 1.2,
        fontWeight: FontWeight.bold,
      ),
      headline6: TextStyle(
        // fontFamily: 'Poppins',
        color: colorScheme.onBackground,
        fontSize: 24,
        height: 1,
      ),
      subtitle1: TextStyle(
        // fontFamily: 'Poppins',
        color: colorScheme.onBackground,
        fontSize: 14,
        height: 1,
      ),
      bodyText1: TextStyle(
        // fontFamily: 'Poppins',
        color: colorScheme.onBackground,
        fontSize: 20,
        height: 1,
      ),
      bodyText2: TextStyle(
        // fontFamily: 'Poppins',
        color: colorScheme.onBackground,
        fontSize: 14,
        height: 1,
      ),
      caption: TextStyle(
        // fontFamily: 'Poppins',
        color: colorScheme.onSurface,
        fontSize: 12,
        height: 1,
      ),
      button: TextStyle(
        // fontFamily: 'Poppins',
        fontSize: 16,
        color: colorScheme.onBackground,
        height: 1,
        fontWeight: FontWeight.w700,
      ),
    );

TextStyle iconStyle() => const TextStyle(
      fontSize: 32,
      color: Color(0xFFFDFDFD),
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle podizStyle() => const TextStyle(
      fontSize: 34,
      color: Color(0xFFFDFDFD),
      height: 1,
      fontWeight: FontWeight.bold,
    );

TextStyle podcastTitle() => const TextStyle(
      fontSize: 18,
      color: Color(0xFFFAFAFA),
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle podcastTitleQuickNote() => const TextStyle(
      fontSize: 16,
      color: Color(0xFF9E9E9E),
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle podcastInsights() => const TextStyle(
      fontSize: 16,
      color: Color(0xFFFFFFFF),
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle podcastInsightsQuickNote() => const TextStyle(
      fontSize: 14,
      color: Color(0xFF9E9E9E),
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle podcastArtist() => const TextStyle(
      fontSize: 16,
      color: Color(0xFF9E9E9E),
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle podcastArtistQuickNote() => const TextStyle(
      fontSize: 14,
      color: Color(0xFF4E4E4E),
      height: 1,
      fontWeight: FontWeight.w400,
    );
