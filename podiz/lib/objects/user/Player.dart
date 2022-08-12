import 'dart:async';

import 'package:podiz/objects/Podcast.dart';
import 'package:rxdart/rxdart.dart';

enum PlayerState {
  play,
  stop,
}

class Player {
  final PlayerState state;
  final Podcast podcast;

  /// podcast duration in seconds
  Duration get duration => Duration(milliseconds: podcast.duration_ms);
  final Duration _startingPosition;

  late final Timer timer;

  /// podcast current playing position in seconds
  final BehaviorSubject<Duration> _positionController =
      BehaviorSubject<Duration>();
  late final Stream<Duration> positionChanges = _positionController.stream;

  /// playing position in seconds
  Duration get position => _positionController.value;

  Player({
    required this.state,
    required this.podcast,
    required Duration startingPosition,
  }) : _startingPosition = startingPosition {
    setTimer();
  }

  bool get isPlaying => state == PlayerState.play;

  void setTimer() {
    switch (state) {
      case PlayerState.play:
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final position = _startingPosition + Duration(seconds: timer.tick);
          if (position == duration) return timer.cancel();
          _positionController.sink.add(position);
        });
        break;
      case PlayerState.stop:
        timer = Timer(Duration.zero, () {});
        break;
    }
  }

  void dispose() {
    timer.cancel();
    _positionController.close();
  }
}

extension PlayerActions on Player {
  Player pause() {
    dispose();
    return Player(
      state: PlayerState.stop,
      podcast: podcast,
      startingPosition: position,
    );
  }
}
