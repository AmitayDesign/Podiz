import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:rxdart/rxdart.dart';

enum PlayerState {
  close,
  play,
  stop,
}

class Player {
  Player() {
    _stateController.add(PlayerState.close);
  }

  Podcast? podcastPlaying;
  bool error = false;
  final StreamController<Duration> _positionController =
      StreamController.broadcast();

  Stream<Duration> get onAudioPositionChanged => _positionController.stream;

  final BehaviorSubject<PlayerState> _stateController =
      BehaviorSubject<PlayerState>();

  Stream<PlayerState> get state => _stateController.stream;

  PlayerState _state = PlayerState.close;

  PlayerState get getState => _state;

  Duration position = Duration.zero;

  startTimer() async {
    Podcast podcastTimer = podcastPlaying!;
    while (podcastTimer.uid == podcastPlaying!.uid &&
        (_state == PlayerState.play &&
            position.inMilliseconds < podcastPlaying!.duration_ms - 200)) {
      _positionController.add(position);
      position = Duration(milliseconds: position.inMilliseconds + 200);
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  Future<void> playEpisode(
      Podcast episode, String userUid, int pos) async {
    HttpsCallableResult<bool> result = await FirebaseFunctions.instance
        .httpsCallable("play")
        .call({"episodeUid": episode.uid, "userUid": userUid, "position": pos});
    podcastPlaying = episode;
    position = Duration(milliseconds: pos);
    if (!result.data) {
      error = true;
      _state = PlayerState.stop;
      _stateController.add(_state);
      return;
    }
    error = false;
    _state = PlayerState.play;
    _stateController.add(_state);
    startTimer();
    return;
  }

  Future<void> resumeEpisode(String userUid) async {
    HttpsCallableResult<bool> result =
        await FirebaseFunctions.instance.httpsCallable("play").call({
      "episodeUid": podcastPlaying!.uid,
      "userUid": userUid,
      "position": position.inMilliseconds,
    });
    if (!result.data) {
      error = true;
      _state = PlayerState.stop;
      _stateController.add(_state);
      return;
    }
    error = false;
    _state = PlayerState.play;
    _stateController.add(_state);
    startTimer();
    return;
  }

  Future<void> pauseEpisode(String userUid) async {
    // TODO verify arguments
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("pause")
        .call({"userUid": userUid});
    _state = PlayerState.stop;
    _stateController.add(_state);
    return;
  }

  void closePlayer() {
    podcastPlaying = null;
    _state = PlayerState.close;
    _stateController.add(_state);
    return;
  }
}
