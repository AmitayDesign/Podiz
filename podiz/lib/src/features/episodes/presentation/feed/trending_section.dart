import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/utils/date_difference.dart';
import 'package:podiz/src/utils/global_key_box.dart';

class TrendingSection with EquatableMixin {
  final key = GlobalKey();
  final String title;
  TrendingSection(DateTime date) : title = generateTitle(date);

  static generateTitle(DateTime date) {
    switch (date.differenceInDays(DateTime.now())) {
      case 0:
        return 'Trending Today';
      case -1:
        return 'Trending Yesterday';
      default:
        final day = date.day.toString().padLeft(2, '0');
        final month = date.month.toString().padLeft(2, '0');
        return 'Trending $day.$month';
    }
  }

  double? get position => key.offset?.dy;
  bool get passed => position != null && position! <= GradientBar.height;

  @override
  List<Object> get props => [title];
}
