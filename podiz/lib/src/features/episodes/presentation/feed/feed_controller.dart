import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/gradientAppBar.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart' hide currentUserProvider;
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';

final feedControllerProvider = StateNotifierProvider<FeedController, String>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    final lastPodcastValue = ref.read(lastListenedPodcastStreamProvider); //!
    return FeedController(user: user, lastPodcastValue: lastPodcastValue);
  },
);

class FeedController extends StateNotifier<String> {
  final lastListenedLocaleKey = 'lastlistened';
  final myCastsLocaleKey = 'mycasts';
  final hotLiveLocaleKey = 'hotlive';
  final myCastsKey = GlobalKey();
  final hotLiveKey = GlobalKey();

  final UserPodiz user; //!
  final AsyncValue<Podcast?> lastPodcastValue; //!

  FeedController({required this.user, required this.lastPodcastValue})
      : super('lastlistened') {
    handleTitles();
  }

  void handleTitles() {
    final myCastsPosition = myCastsKey.offset?.dy;
    final hotLivePosition = hotLiveKey.offset?.dy;

    final lastPodcastExists =
        lastPodcastValue.isLoading || lastPodcastValue.valueOrNull != null;
    final myCastsDidNotPass = user.favPodcastIds.isEmpty ||
        myCastsPosition == null ||
        myCastsPosition > GradientAppBar.height;
    final hotLiveDidNotPass =
        hotLivePosition == null || hotLivePosition > GradientAppBar.height;

    if (lastPodcastExists &&
        user.lastPodcastId.isNotEmpty &&
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
