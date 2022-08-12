import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/TimerPodiz.dart';
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

  final BehaviorSubject<PlayerState> _stateController =
      BehaviorSubject<PlayerState>();

  Stream<PlayerState> get state => _stateController.stream;

  PlayerState _state = PlayerState.close;

  PlayerState get getState => _state;

  TimerPodiz timer = TimerPodiz("");

  setUpPodcastStream(String podcastUid) async {
    if (!firstTime) {
      await podcastStreamSubscription!.cancel();
      await _podcastController!.close();
    }
    firstTime = false;
    _podcastController = BehaviorSubject<Podcast>();
    podcastStreamSubscription = FirebaseFirestore.instance
        .collection("podcasts")
        .doc(podcastUid)
        .snapshots()
        .listen((doc) async {
      if (doc.data() != null) {
        podcastPlaying = Podcast.fromFirestore(doc);
        _podcastController!.add(podcastPlaying!);
      }
    });
  }

  Future<void> playEpisode(Podcast episode, String userUid, int pos) async {
    if (podcastPlaying != null && podcastPlaying!.uid != episode.uid) {
      setUpPodcastStream(episode.uid!);
    } else if (podcastPlaying == null) {
      setUpPodcastStream(episode.uid!);
    }

    var result = await FirebaseFunctions
        .instance
        .httpsCallable("play")
        .call({"episodeUid": episode.uid, "userUid": userUid, "position": pos});
    podcastPlaying = episode;
    _podcastController!.add(episode);
    print(result.data);
    
    if (result.data["result"] == "unauthorized") {
      //TODO view
      error = true;
      _state = PlayerState.stop;
      _stateController.add(_state);
      return;
    }
    if (result.data["result"] == "devices") {
      //TODO no device Page
      error = true;
      _state = PlayerState.stop;
      _stateController.add(_state);
      return;
    }
    print("here");
    playTimer(episode, pos);
    error = false;
    _state = PlayerState.play;
    _stateController.add(_state);
    print(_state);
    return;
  }

  void playTimer(Podcast episode, int position) async {
    timer.setIsPlaying(false);
    await Future.delayed(const Duration(milliseconds: 200));
    timer.setPosition(Duration(milliseconds: position));
    timer.setDuration(Duration(milliseconds: episode.duration_ms));
    timer.setIsPlaying(true);
    timer.timerStart();
  }

  Future<void> pauseEpisode(String userUid) async {
    var result = await FirebaseFunctions
        .instance
        .httpsCallable("pause")
        .call({"userUid": userUid});
        print(result.data);
    if (result.data["result"] == "unauthorized") {
      //TODO view

      return;
    }
    if (result.data["result"] == "devices") {
      //TODO no device Page

      return;
    }
    _state = PlayerState.stop;
    _stateController.add(_state);
    timer.setIsPlaying(false);
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
