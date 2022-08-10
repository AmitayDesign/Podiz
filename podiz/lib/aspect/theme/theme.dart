import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/themeConfig.dart';

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
      contentPadding: const EdgeInsets.symmetric(
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size.fromHeight(kButtonHeight),
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
      backgroundColor: const Color(0xE6090909),
      selectedItemColor: const Color(0xFFD74EFF),
      unselectedItemColor: const Color(0xB2FFFFFF),
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
      ),
      bodyText1: TextStyle(
        fontFamily: 'Montserrat',
        color: colorScheme.onBackground,
        fontSize: 20,
      ),
      bodyText2: TextStyle(
        fontFamily: 'Montserrat',
        color: colorScheme.onBackground,
        fontSize: 14,
      ),
      caption: TextStyle(
        fontFamily: 'Montserrat',
        color: colorScheme.onSurface,
        fontSize: 12,
      ),
      button: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        color: Palette.pureWhite,
        fontWeight: FontWeight.w800,
      ),
    );

TextStyle iconStyle() => const TextStyle(
      fontSize: 32,
      fontFamily: 'Montserrat',
      color: Color(0xFFFDFDFD),
      fontWeight: FontWeight.w800,
    );

TextStyle podizStyle() => const TextStyle(
      fontSize: 34,
      fontFamily: 'Montserrat',
      color: Color(0xFFFDFDFD),
      fontWeight: FontWeight.bold,
    );

TextStyle podcastTitle() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      color: Color(0xFFFAFAFA),
      fontWeight: FontWeight.w800,
      overflow: TextOverflow.ellipsis,
    );
TextStyle podcastTitlePlaying() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      color: Palette.purple,
      fontWeight: FontWeight.w800,
      overflow: TextOverflow.ellipsis,
    );

TextStyle discussionAppBarTitle() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xFFFAFAFA),
      fontWeight: FontWeight.w800,
    );

TextStyle podcastTitleQuickNote() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xFF9E9E9E),
      fontWeight: FontWeight.w800,
      overflow: TextOverflow.ellipsis,
    );

TextStyle podcastInsights() => const TextStyle(
      fontFamily: 'Montserrat',
      color: Palette.pureWhite,
      fontWeight: FontWeight.w500,
    );

TextStyle podcastInsightsQuickNote() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xFF9E9E9E),
      fontWeight: FontWeight.w500,
    );

TextStyle podcastArtist() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xFF9E9E9E),
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis,
    );

TextStyle podcastArtistQuickNote() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xFF4E4E4E),
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis,
    );

TextStyle discussionAppBarInsights() => const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    color: Color(0xB2FFFFFF),
    fontWeight: FontWeight.w500,
    overflow: TextOverflow.ellipsis);

TextStyle discussionCardProfile() => const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    color: Palette.pureWhite,
    fontWeight: FontWeight.w800,
    overflow: TextOverflow.ellipsis);

TextStyle discussionCardFollowers() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xFF9E9E9E),
      fontWeight: FontWeight.w500,
    );

TextStyle discussionCardComment() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Palette.pureWhite,
      fontWeight: FontWeight.w500,
    );

TextStyle discussionCardPlay() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xE6FFFFFF),
      fontWeight: FontWeight.w800,
    );

TextStyle discussionCardCommentHint() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 12,
      color: Color(0xFF9E9E9E),
      fontWeight: FontWeight.w500,
    );

TextStyle discussionSnackCommentHint() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xE6FFFFFF),
      fontWeight: FontWeight.w500,
    );

TextStyle discussionSnackPlay() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Palette.pureWhite,
      fontWeight: FontWeight.w800,
    );

TextStyle followerName() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20,
      color: Palette.pureWhite,
      fontWeight: FontWeight.w800,
    );

TextStyle followersNumber() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      color: Color(0xE6FFFFFF),
      fontWeight: FontWeight.w800,
    );

TextStyle followersText() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xE6FFFFFF),
      fontWeight: FontWeight.w500,
    );
TextStyle followersFavorite() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xE6FFFFFF),
      fontWeight: FontWeight.w800,
    );

TextStyle selectedLabel() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      fontWeight: FontWeight.w800,
    );

TextStyle unselectedLabel() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      fontWeight: FontWeight.w800,
    );

TextStyle notificationsSelectedLabel() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Color(0xE6FFFFFF),
    );

TextStyle notificationsUnselectedLabel() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xE6FFFFFF),
    );

TextStyle showFollowing() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      color: Color(0xB2FFFFFF),
      fontWeight: FontWeight.w500,
    );

TextStyle showDescription() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Palette.pureWhite,
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.w500,
    );

TextStyle noInternetTitle() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 36,
      color: Palette.pureWhite,
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.w800,
    );

TextStyle ffffffff14700() => const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.w800,
    );
