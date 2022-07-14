import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/objects/Podcast.dart';

enum PlayerState {
  close,
  play,
  stop,
}

class Player {
  Player();

  PlayerState playingState = PlayerState.close;
  Podcast? podcastPlaying;

  Future<void> playEpisode(Podcast episode, String userUid) async {
    // TODO verify arguments
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("play")
        .call({"episodeUid": episode.uid, "userUid": userUid});
    playingState = PlayerState.play;
    podcastPlaying = episode;
    return;
  }

  Future<void> pauseEpisode(String userUid) async {
    // TODO verify arguments
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("pause")
        .call({"userUid": userUid});
    playingState = PlayerState.stop;
    return;
  }

  Future<void> resumeEpisode(String userUid) async {
    // TODO verify arguments
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("resume")
        .call({"userUid": userUid});
    playingState = PlayerState.play;
    return;
  }

  void closePlayer() {
    playingState = PlayerState.close;
    podcastPlaying = null;
    return;
  }
}
