import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/gradientAppBar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';

final feedControllerProvider = StateNotifierProvider<FeedController, String>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    return FeedController(user: user);
  },
);

class FeedController extends StateNotifier<String> {
  final lastListenedLocaleKey = 'lastlistened';
  final myCastsLocaleKey = 'mycasts';
  final hotLiveLocaleKey = 'hotlive';
  final myCastsKey = GlobalKey();
  final hotLiveKey = GlobalKey();

  final UserPodiz user;

  FeedController({required this.user}) : super('lastlistened') {
    handleTitles();
  }

  void handleTitles() {
    final myCastsPosition = myCastsKey.offset?.dy;
    final hotLivePosition = hotLiveKey.offset?.dy;

    final lastPodcastExists = user.lastListenedEpisodeId.isNotEmpty;
    final myCastsDidNotPass = user.favPodcastIds.isEmpty ||
        myCastsPosition == null ||
        myCastsPosition > GradientAppBar.height;
    final hotLiveDidNotPass =
        hotLivePosition == null || hotLivePosition > GradientAppBar.height;

    if (lastPodcastExists &&
        user.lastListenedEpisodeId.isNotEmpty &&
        myCastsDidNotPass &&
        hotLiveDidNotPass) {
      state = lastListenedLocaleKey;
    } else if (user.favPodcastIds.isNotEmpty && hotLiveDidNotPass) {
      state = myCastsLocaleKey;
    } else {
      state = hotLiveLocaleKey;
    }
  }
}
