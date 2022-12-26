import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/utils/global_key_box.dart';

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

    final lastPodcastExists = user.lastListened != null;
    final myCastsDidNotPass = user.favPodcasts.isEmpty ||
        myCastsPosition == null ||
        myCastsPosition > GradientBar.height;
    final hotLiveDidNotPass =
        hotLivePosition == null || hotLivePosition > GradientBar.height;

    if (lastPodcastExists && myCastsDidNotPass && hotLiveDidNotPass) {
      state = lastListenedLocaleKey;
    } else if (user.favPodcasts.isNotEmpty && hotLiveDidNotPass) {
      state = myCastsLocaleKey;
    } else {
      state = hotLiveLocaleKey;
    }
  }
}
