import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/statistics/mix_panel.dart';

final mixPanelRepository =
    Provider<MixPanelRepository>((ref) => MixPanelManager());

abstract class MixPanelRepository {
  Future<void> init();
  void userComment();
  void userReply();
  void userFollowUser();
  void userFollowPodcast();
  void userOpenPodcast();
  void userShare();
  void openApp();
}
