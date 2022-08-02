import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class TimerPodiz {
  TimerPodiz(this.episodeUid);

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  String episodeUid;
  bool isPlaying = false;

  String get podcast => episodeUid;

  void setIsPlaying(bool p) {
    isPlaying = p;
  }

  void setTimer(Duration d, Duration p) {
    setDuration(d);
    setPosition(p);
  }

  void setPosition(Duration p) {
    position = p;
  }

  void setDuration(Duration d) {
    duration = d;
  }

  final StreamController<Duration> _positionController =
      StreamController.broadcast();

  Stream<Duration> get onAudioPositionChanged => _positionController.stream;

  void timerStart() async {
    while (
        isPlaying && position.inMilliseconds < duration.inMilliseconds - 200) {
      _positionController.add(position);
      position = Duration(milliseconds: position.inMilliseconds + 200);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (position.inMilliseconds >= duration.inMilliseconds - 200) {
      decrement(podcast);
      episodeUid = "";
    }
  }

  void decrement(String episodeUid) {
    FirebaseFirestore.instance
        .collection("podcasts")
        .doc(episodeUid)
        .update({"watching": FieldValue.increment(-1)});
  }
}
