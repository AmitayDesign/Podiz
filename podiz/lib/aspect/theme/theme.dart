import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        onPrimary: Palette.pureWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size.fromHeight(56),
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

TextTheme _textTheme(ColorScheme colorScheme) =>
    GoogleFonts.montserratTextTheme(
      TextTheme(
        headline4: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 40,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        headline5: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        subtitle1: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyText1: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        bodyText2: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        caption: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        button: const TextStyle(
          fontSize: 16,
          color: Palette.pureWhite,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

TextStyle iconStyle() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 32,
        color: Color(0xFFFDFDFD),
        fontWeight: FontWeight.w700,
      ),
    );

TextStyle podizStyle() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 34,
        color: Color(0xFFFDFDFD),
        fontWeight: FontWeight.w700,
      ),
    );

TextStyle podcastTitle() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 18,
        color: Color(0xFFFAFAFA),
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      ),
    );
TextStyle podcastTitlePlaying() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 18,
        color: Palette.purple,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      ),
    );

TextStyle discussionAppBarTitle() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xFFFAFAFA),
        fontWeight: FontWeight.w800,
      ),
    );

TextStyle podcastTitleQuickNote() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xFF9E9E9E),
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      ),
    );

TextStyle podcastInsights() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        color: Palette.pureWhite,
        fontWeight: FontWeight.w500,
      ),
    );
TextStyle podcastInsightsQuickNote() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF9E9E9E),
        fontWeight: FontWeight.w500,
      ),
    );

TextStyle podcastArtist() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xFF9E9E9E),
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      ),
    );

TextStyle podcastArtistQuickNote() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF4E4E4E),
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      ),
    );

TextStyle discussionAppBarInsights() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xB2FFFFFF),
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      ),
    );

TextStyle discussionCardProfile() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Palette.pureWhite,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      ),
    );

TextStyle discussionCardFollowers() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF9E9E9E),
        fontWeight: FontWeight.w500,
      ),
    );

TextStyle discussionCardComment() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Palette.pureWhite,
        fontWeight: FontWeight.w500,
      ),
    );

TextStyle discussionCardPlay() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xE6FFFFFF),
        fontWeight: FontWeight.w800,
      ),
    );

TextStyle discussionCardCommentHint() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xFF9E9E9E),
        fontWeight: FontWeight.w500,
      ),
    );

TextStyle discussionSnackCommentHint() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xE6FFFFFF),
        fontWeight: FontWeight.w500,
      ),
    );

TextStyle discussionSnackPlay() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Palette.pureWhite,
        fontWeight: FontWeight.w800,
      ),
    );

TextStyle followerName() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 20,
        color: Palette.pureWhite,
        fontWeight: FontWeight.w800,
      ),
    );

TextStyle followersNumber() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 18,
        color: Color(0xE6FFFFFF),
        fontWeight: FontWeight.w800,
      ),
    );

TextStyle followersText() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xE6FFFFFF),
        fontWeight: FontWeight.w500,
      ),
    );
TextStyle followersFavorite() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xE6FFFFFF),
        fontWeight: FontWeight.w800,
      ),
    );

TextStyle selectedLabel() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
TextStyle unselectedLabel() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
TextStyle notificationsSelectedLabel() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xE6FFFFFF),
      ),
    );

TextStyle notificationsUnselectedLabel() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xE6FFFFFF),
      ),
    );

TextStyle showFollowing() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xB2FFFFFF),
        fontWeight: FontWeight.w500,
      ),
    );

TextStyle showDescription() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        color: Palette.pureWhite,
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.w500,
      ),
    );

TextStyle noInternetTitle() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 36,
        color: Palette.pureWhite,
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.w800,
      ),
    );

TextStyle ffffffff14700() => GoogleFonts.montserrat(
      textStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.w800,
      ),
    );
