import 'package:flutter/cupertino.dart';

const kBorderRadius = 10.0;
const kSheetBorderRadius = 24.0;
const kSmallIconSize = 18.0;
const kButtonHeight = 50.0;
late double kScreenHeight;
late double kScreenWidth;

bool _hasScreenSize = false;
void setScreenSize(BuildContext context) {
  if (_hasScreenSize) return;
  final mediaQuery = MediaQuery.of(context);
  kScreenHeight = mediaQuery.size.height - mediaQuery.padding.top;
  kScreenWidth = mediaQuery.size.width;
  _hasScreenSize = true;
}
