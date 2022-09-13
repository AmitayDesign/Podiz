import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';

class MixPanelManager implements MixPanelRepository {
  late Mixpanel mixpanel;

  @override
  void init() async {
    mixpanel = await Mixpanel.init("d293ecfa9c2739d850381d9e245b7437",
        optOutTrackingDefault: false);
  }

  @override
  void userComment() {
    mixpanel.track("userComment");
  }

  @override
  void userReply() {
    mixpanel.track("userReply");
  }

  @override
  void userFollowUser() {
    mixpanel.track("userFollowUser");
  }

  @override
  void userFollowPodcast() {
    mixpanel.track("userFollowPodcast");
  }

  @override
  void userOpenPodcast() {
    mixpanel.track("userOpenPodcast");
  }

  @override
  void userShare() {
    mixpanel.track("userShare");
  }

  @override
  void openApp() {
    mixpanel.track("openApp");
  }
}
