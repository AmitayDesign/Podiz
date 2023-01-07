import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/date_difference.dart';
import 'package:podiz/src/utils/global_key_box.dart';

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
    final trendingDidNotPass = trending.isEmpty || trending.first.didNotPass;

    if (lastPodcastExists && myCastsDidNotPass && trendingDidNotPass) {
      state = lastListenedTitle;
    } else if (user.favPodcasts.isNotEmpty && trendingDidNotPass) {
      state = myCastsTitle;
    } else if (trending.isNotEmpty) {
      for (var i = 0; i < trending.length - 1; i++) {
        if (trending[i + 1].didNotPass) {
          state = trending[i].title;
          return;
        }
      }
      state = trending.last.title;
    }
  }
}

class TrendingSection with EquatableMixin {
  final key = GlobalKey();
  final String title;
  TrendingSection(DateTime date) : title = generateTitle(date);

  static generateTitle(DateTime date) {
    switch (date.differenceInDays(DateTime.now())) {
      case 0:
        return 'Trending Today';
      case 1:
        return 'Trending Yesterday';
      default:
        final day = date.day.toString().padLeft(2, '0');
        final month = date.month.toString().padLeft(2, '0');
        return 'Trending $day.$month';
    }
  }

  bool get didNotPass {
    final position = key.offset?.dy;
    return position == null || position > GradientBar.height;
  }

  @override
  List<Object> get props => [title];
}
