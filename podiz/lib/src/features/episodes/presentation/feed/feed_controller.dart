import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/global_key_box.dart';

import 'trending_section.dart';

final lastTrendingDayLoadedProvider = StateProvider<int>((ref) => -1);

final feedControllerProvider = StateNotifierProvider<FeedController, String>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    return FeedController(user: user);
  },
);

class FeedController extends StateNotifier<String> {
  final lastListenedTitle = 'Last Listened';
  final myCastsTitle = 'My Casts';
  final myCastsKey = GlobalKey();
  final trending = <TrendingSection>[];

  final UserPodiz user;

  FeedController({required this.user}) : super('Last Listened') {
    handleTitles();
  }

  void handleTitles() {
    final myCastsPosition = myCastsKey.offset?.dy;

    final lastPodcastExists = user.lastListened != null;
    final myCastsDidNotPass = user.favPodcasts.isEmpty ||
        myCastsPosition == null ||
        myCastsPosition > GradientBar.height;

    if (lastPodcastExists && myCastsDidNotPass && _trendingDidNotPass()) {
      state = lastListenedTitle;
    } else if (user.favPodcasts.isNotEmpty && _trendingDidNotPass()) {
      state = myCastsTitle;
    } else if (trending.isNotEmpty) {
      final section =
          trending.reversed.firstWhereOrNull((section) => section.passed);
      if (section != null) state = section.title;
    }
  }

  bool _trendingDidNotPass() {
    if (trending.isEmpty) return true;
    if (trending.first.position != null &&
        trending.first.position! > GradientBar.height) return true;
    if (trending.first.position != null &&
        trending.first.position! <= GradientBar.height) return false;
    return !trending.any((section) => section.position != null);
  }
}
