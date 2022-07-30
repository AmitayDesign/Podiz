import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/themeConfig.dart';
import 'package:flutter/material.dart';

ThemeData theme(ColorScheme colorScheme) => ThemeData(
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      backgroundColor: colorScheme.background,
      errorColor: colorScheme.error,
      scaffoldBackgroundColor: colorScheme.background,
      canvasColor: colorScheme.background,
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
      fillColor: Palette.grey900,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(30),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      hintStyle: discussionCardCommentHint(),
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
      selectedLabelStyle: selectedLabel(),
      unselectedLabelStyle: unselectedLabel(),
      elevation: 0,
      backgroundColor: Color(0xE6090909),
      selectedItemColor: Color(0xFFD74EFF),
      unselectedItemColor: Color(0xB2FFFFFF),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );

TextTheme _textTheme(ColorScheme colorScheme) => TextTheme(
      headline5: TextStyle(
        fontFamily: 'Montserrat',
        color: colorScheme.onBackground,
        fontSize: 40,
        fontWeight: FontWeight.w600,
      ),
      headline6: TextStyle(
          fontFamily: 'Montserrat',
          color: colorScheme.onBackground,
          fontSize: 24,
          fontWeight: FontWeight.w600),
      subtitle1: TextStyle(
        fontFamily: 'Montserrat',
        color: colorScheme.onBackground,
        fontSize: 14,
        height: 1,
      ),
      bodyText1: TextStyle(
        fontFamily: 'Montserrat',
        color: colorScheme.onBackground,
        fontSize: 20,
        height: 1,
      ),
      bodyText2: TextStyle(
        fontFamily: 'Montserrat',
        color: colorScheme.onBackground,
        fontSize: 14,
        height: 1,
      ),
      caption: TextStyle(
        fontFamily: 'Montserrat',
        color: colorScheme.onSurface,
        fontSize: 12,
        height: 1,
      ),
      button: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        color: Palette.pureWhite,
        fontWeight: FontWeight.w700,
      ),
    );

TextStyle iconStyle() => const TextStyle(
      fontSize: 32,
      fontFamily: 'Montserrat',
      color: Color(0xFFFDFDFD),
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle podizStyle() => const TextStyle(
      fontSize: 34,
      fontFamily: 'Montserrat',
      color: Color(0xFFFDFDFD),
      height: 1,
      fontWeight: FontWeight.bold,
    );

TextStyle podcastTitle() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      color: Color(0xFFFAFAFA),
      height: 1,
      fontWeight: FontWeight.w700,
      overflow: TextOverflow.ellipsis,
    );
TextStyle podcastTitlePlaying() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      color: Palette.purple,
      height: 1,
      fontWeight: FontWeight.w700,
      overflow: TextOverflow.ellipsis,
    );

TextStyle discussionAppBarTitle() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xFFFAFAFA),
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle podcastTitleQuickNote() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xFF9E9E9E),
      height: 1,
      fontWeight: FontWeight.w700,
      overflow: TextOverflow.ellipsis,
    );

TextStyle podcastInsights() => const TextStyle(
      fontFamily: 'Montserrat',
      color: Palette.pureWhite,
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle podcastInsightsQuickNote() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xFF9E9E9E),
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle podcastArtist() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xFF9E9E9E),
      height: 1,
      fontWeight: FontWeight.w400,
      overflow: TextOverflow.ellipsis,
    );

TextStyle podcastArtistQuickNote() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xFF4E4E4E),
      height: 1,
      fontWeight: FontWeight.w400,
      overflow: TextOverflow.ellipsis,
    );

TextStyle discussionAppBarInsights() => const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    color: Color(0xB2FFFFFF),
    height: 1,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis);

TextStyle discussionCardProfile() => const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    color: Palette.pureWhite,
    height: 1,
    fontWeight: FontWeight.w700,
    overflow: TextOverflow.ellipsis);

TextStyle discussionCardFollowers() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xFF9E9E9E),
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle discussionCardComment() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Palette.pureWhite,
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle discussionCardPlay() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xE6FFFFFF),
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle discussionCardCommentHint() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 12,
      color: Color(0xFF9E9E9E),
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle discussionSnackCommentHint() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xE6FFFFFF),
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle discussionSnackPlay() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Palette.pureWhite,
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle followerName() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20,
      color: Palette.pureWhite,
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle followersNumber() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      color: Color(0xE6FFFFFF),
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle followersText() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xE6FFFFFF),
      height: 1,
      fontWeight: FontWeight.w400,
    );
TextStyle followersFavorite() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xE6FFFFFF),
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle selectedLabel() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle unselectedLabel() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      height: 1,
      fontWeight: FontWeight.w700,
    );

TextStyle notificationsSelectedLabel() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      height: 1,
      fontWeight: FontWeight.w700,
      color: Color(0xE6FFFFFF),
    );

TextStyle notificationsUnselectedLabel() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      height: 1,
      fontWeight: FontWeight.w400,
      color: Color(0xE6FFFFFF),
    );

TextStyle showFollowing() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xB2FFFFFF),
      height: 1,
      fontWeight: FontWeight.w400,
    );

TextStyle showDescription() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Palette.pureWhite,
      height: 1,
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.w400,
    );

TextStyle noInternetTitle() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 36,
      color: Palette.pureWhite,
      height: 1,
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.w700,
    );
