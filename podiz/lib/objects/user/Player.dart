import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
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

  Stream<Podcast> get podcast => _podcastController!.stream;

  BehaviorSubject<Podcast>? _podcastController;

  StreamSubscription<DocumentSnapshot<Object?>>? podcastStreamSubscription;

  bool firstTime = true;

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
    if (podcastPlaying!.duration_ms - 200 <= position.inMilliseconds) {
      decrement(podcastPlaying!.uid!);
    }
  }

  setUpPodcastStream(String podcastUid) async {
    if (!firstTime) {
      await podcastStreamSubscription!.cancel();
      await _podcastController!.close();
      podcastPlaying = null;
    }
    firstTime = false;
    _podcastController = BehaviorSubject<Podcast>();
    podcastStreamSubscription = FirebaseFirestore.instance
        .collection("podcasts")
        .doc(podcastUid)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        podcastPlaying = Podcast.fromJson(snapshot.data()!);
        _podcastController?.add(podcastPlaying!);
      }
    });
  }

  Future<void> playEpisode(Podcast episode, String userUid, int pos) async {
    if (podcastPlaying == null) {
      increment(episode.uid!);
      _podcastController?.add(episode);
      setUpPodcastStream(episode.uid!);
    } else if (podcastPlaying!.uid! != episode.uid) {
      increment(episode.uid!);
      decrement(podcastPlaying!.uid!);
      _podcastController?.add(episode);
      setUpPodcastStream(episode.uid!);
    }
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

  void increment(String episodeUid) {
    FirebaseFirestore.instance
        .collection("podcasts")
        .doc(episodeUid)
        .update({"watching": FieldValue.increment(1)});
  }

  void decrement(String episodeUid) {
    FirebaseFirestore.instance
        .collection("podcasts")
        .doc(episodeUid)
        .update({"watching": FieldValue.increment(-1)});
  }
}
