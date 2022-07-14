import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension BrightnessX on Brightness {
  bool get isLight => this == Brightness.light;
  bool get isDark => this == Brightness.dark;
  Brightness get other => isLight ? Brightness.dark : Brightness.light;
}

const _themeModeKey = 'themeMode';
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) {
    final mode = preferences.getInt(_themeModeKey);
    return mode == null ? ThemeMode.system : ThemeMode.values[mode];
  },
);

final brightnessProvider = StateNotifierProvider<ThemeConfig, Brightness>(
  (ref) {
    final mode = ref.watch(themeModeProvider);
    Brightness brightness;
    brightness = Brightness.dark;
    // switch (mode) {
    //   case ThemeMode.light:
    //     brightness = Brightness.light;
    //     break;
    //   case ThemeMode.dark:
    //     brightness = Brightness.dark;
    //     break;
      // case ThemeMode.system:
      // default:
      //   brightness = SchedulerBinding.instance!.window.platformBrightness;
      //   break;
    // }
    return ThemeConfig(mode, brightness);
  },
);

class ThemeConfig extends StateNotifier<Brightness> {
  final ThemeMode _mode;

  ThemeConfig(this._mode, Brightness brightness) : super(brightness) {
    preferences.setInt(_themeModeKey, _mode.index);
    setSystemBarsStyle();
  }

  void update() {
    if (_mode == ThemeMode.system) {
      state = SchedulerBinding.instance.window.platformBrightness;
      setSystemBarsStyle();
    }
  }

  void setSystemBarsStyle({
    bool transparentStatusBar = true,
    Color? systemNavigationBarColor,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      overlayStyle(
        state,
        transparentStatusBar: transparentStatusBar,
        systemNavigationBarColor: systemNavigationBarColor,
      ),
    );
  }

  static ThemeData get light => theme(Palette.colorScheme);
  // static ThemeData get dark => theme(Palette.darkColorScheme);

  static SystemUiOverlayStyle overlayStyle(
    Brightness brightness, {
    bool transparentStatusBar = true,
    Color? systemNavigationBarColor,
  }) {
    final color = Palette.colorScheme.background;
        
    return SystemUiOverlayStyle(
      statusBarColor: transparentStatusBar ? Colors.transparent : color,
      statusBarBrightness: brightness.other,
      statusBarIconBrightness: brightness.other,
      systemNavigationBarIconBrightness: brightness.other,
      systemNavigationBarColor: systemNavigationBarColor ?? color,
    );
  }
}
