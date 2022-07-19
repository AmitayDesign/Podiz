import 'dart:async';

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

  Podcast? podcastPlaying;

  final StreamController<Duration> _positionController =
      StreamController.broadcast();

  PlayerState _state = PlayerState.close;

  PlayerState get state => _state;

  Duration position = Duration.zero;

  Stream<Duration> get onAudioPositionChanged => _positionController.stream;

  startTimer() async {
    Podcast podcastTimer = podcastPlaying!;
    while (podcastTimer.uid == podcastPlaying!.uid &&
        (_state == PlayerState.play ||
            position.inMilliseconds >= podcastPlaying!.duration_ms)) {
      _positionController.add(position);
      position = Duration(milliseconds: position.inMilliseconds + 200);
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  Future<void> playEpisode(Podcast episode, String userUid) async {
    // TODO verify arguments
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("play")
        .call({"episodeUid": episode.uid, "userUid": userUid});
    podcastPlaying = episode;
    position = Duration.zero;
    _state = PlayerState.play;
    startTimer();
    return;
  }

  Future<void> pauseEpisode(String userUid) async {
    // TODO verify arguments
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("pause")
        .call({"userUid": userUid});
    _state = PlayerState.stop;
    return;
  }

  Future<void> resumeEpisode(String userUid) async {
    // TODO verify arguments
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("resume")
        .call({"userUid": userUid});
    _state = PlayerState.play;
    startTimer();
    return;
  }

  void closePlayer() {
    podcastPlaying = null;
    return;
  }
}
