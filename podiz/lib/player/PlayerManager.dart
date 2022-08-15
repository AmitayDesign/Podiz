import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final playerManagerProvider = Provider<PlayerManager>(
  (ref) => PlayerManager(ref.read),
);

class PlayerManager {
  final Reader _read;

  AuthManager get authManager => _read(authManagerProvider);
  PodcastManager get podcastManager => _read(podcastManagerProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);
  FirebaseFunctions get functions => _read(functionsProvider);

  final _playerController = BehaviorSubject<Player?>();
  Stream<Player?> get playerStream => _playerController.stream;
  Player? get currentPlayer => _playerController.value;

  PlayerManager(this._read) {
    // _init();
  }

  Future<void> _init() async {
    // make a spotify request to fetch the currently playing podcast
    final user = authManager.currentUser!;
    final result = await FirebaseFunctions.instance
        .httpsCallable("fetchUserPlayer")
        .call({"userUid": user.id});
    final data = result.data;

    if (data is bool && !data) return _playerController.add(null);

    final isPlaying = data['isPlaying'] as bool;
    if (!isPlaying) return _playerController.add(null);

    final podcastId = data['uid'] as String;
    final position = data['position'] as int;

    // fetch podcast
    final podcast = await podcastManager.fetchPodcast(podcastId);
    final player = Player(
      state: PlayerState.play,
      podcast: podcast,
      startingPosition: Duration(milliseconds: position),
    );
    _playerController.add(player);
  }

  /// position in milliseconds
  Future<void> playPodcast(Podcast podcast, [int? position]) async {
    // make a spotify request to play the podcast
    if (position == null && currentPlayer?.podcast == podcast) return;
    position ??= 0;

    // _playPodcastRequest(podcast, position);

    // update player
    currentPlayer?.dispose();
    final player = Player(
      state: PlayerState.play,
      podcast: podcast,
      startingPosition: Duration(milliseconds: position),
    );
    _playerController.add(player);

    authManager.updateLastListened(podcast.uid!);
    setUpDiscussionPageStream(podcast.uid!); //TODO discussion
  }

  Future<void> resumePodcast() => playPodcast(
      currentPlayer!.podcast, currentPlayer!.position.inMilliseconds);

  Future<void> pausePodcast() async {
    // await _pausePodcastRequest();
    // update player
    final player = currentPlayer!.pause();
    _playerController.add(player);
  }

  Future<void> stopPodcast() async {
    // make a spotify request to pause the podcast
    // if (_playerController.hasValue) await _pausePodcastRequest();
    // update player
    currentPlayer?.dispose();
    _playerController.add(null);
  }

  Future<void> _playPodcastRequest(Podcast podcast, int position) async {
    // make a spotify request to play the podcast
    final user = authManager.currentUser!;
    final result = await functions.httpsCallable("play").call(
        {"episodeUid": podcast.uid, "userUid": user.id, "position": position});

    // check if the request was successfull
    if (result.data['result'] == 'unauthorized') {
      _playerController.add(null);
      throw Exception('Unauthorized');
    }
    if (result.data['result'] == 'devices') {
      _playerController.add(null);
      throw Exception('No devices connected');
    }
  }

  Future<void> _pausePodcastRequest() async {
    // make a spotify request to pause the podcast
    final user = authManager.currentUser!;
    final result = await FirebaseFunctions.instance
        .httpsCallable("pause")
        .call({"userUid": user.id});
    // check if the request was successfull
    if (result.data['result'] == 'unauthorized') {
      _playerController.add(null);
      throw Exception('Unauthorized');
    }
    if (result.data['result'] == 'devices') {
      _playerController.add(null);
      throw Exception('No devices connected');
    }
  }

  Future<void> play30Back() async {
    var position = _playerController.value!.position;
    const decrement = Duration(seconds: 30);
    if (position < decrement) {
      position = Duration.zero;
    } else {
      position -= decrement;
    }

    final podcast = _playerController.value!.podcast;
    await playPodcast(podcast, position.inMilliseconds);
  }

  Future<void> play30Up() async {
    var position = _playerController.value!.position;
    var duration = _playerController.value!.duration;
    const increment = Duration(seconds: 30);
    if (position + increment > duration) {
      position = duration;
    } else {
      position += increment;
    }

    await pausePodcast();
  }

  Future<void> increment(String podcastId) => FirebaseFirestore.instance
      .collection("podcasts")
      .doc(podcastId)
      .update({"watching": FieldValue.increment(1)});

  Future<void> decrement(String podcastId) => FirebaseFirestore.instance
      .collection("podcasts")
      .doc(podcastId)
      .update({"watching": FieldValue.increment(-1)});

  //! DISCUSSION

  BehaviorSubject<List<Comment>>? _commentsStream;

  Stream<List<Comment>> get comments => _commentsStream!.stream;

  StreamSubscription<QuerySnapshot>? commentsStreamSubscription;

  Map<String, Comment> commentsBloc = {}; //change this

  List<Comment> commentsOrdered = [];

  int index = 0;

  bool firstTime = true;
  bool showAll = false;
  setUpDiscussionPageStream(String podcastUid) async {
    if (!firstTime) {
      await commentsStreamSubscription!.cancel();
      await _commentsStream!.close();
      commentsBloc = {};
      commentsOrdered = [];
    }
    index = 0;
    firstTime = false;
    bool flag = false;
    showAll = false;
    _commentsStream = BehaviorSubject<List<Comment>>();
    commentsStreamSubscription = firestore
        .collection("podcasts")
        .doc(podcastUid)
        .collection("comments")
        .orderBy("lvl")
        .snapshots()
        .listen((snapshot) async {
      for (DocChange commentChange in snapshot.docChanges) {
        if (commentChange.type == DocumentChangeType.added) {
          await addCommentToBloc(commentChange.doc);
        }
      }
      commentsOrdered = getOrderedComments();
      if (!flag) {
        _commentsStream!.add([]);
      }
      flag = true;
    });
  }

  addCommentToBloc(Doc doc) {
    Comment comment = Comment.fromFirestore(doc);
    Map<String, Comment> replies = {};
    comment.replies = replies;
    if (comment.lvl == 1) {
      commentsBloc.addAll({doc.id: comment});
    } else if (comment.lvl == 2) {
      commentsBloc[comment.parents[0]]!.replies!.addAll({doc.id: comment});
    } else if (comment.lvl == 3) {
      commentsBloc[comment.parents[0]]!
          .replies![comment.parents[1]]!
          .replies!
          .addAll({doc.id: comment});
    } else if (comment.lvl == 4) {
      commentsBloc[comment.parents[0]]!
          .replies![comment.parents[1]]!
          .replies![comment.parents[2]]!
          .replies!
          .addAll({doc.id: comment});
    }
  }

  void activateSpoilerAlert() {
    showAll = true;
    //TODO needs to refactor maybe
  }

  showComments(int time) {
    if (showAll) {
      _commentsStream?.add(commentsOrdered.reversed.toList());
      return;
    }
    int i;
    for (i = index; i < commentsOrdered.length; i++) {
      if (commentsOrdered[i].time > time) {
        break;
      }
    }
    if (i > index) {
      if (commentsOrdered.isNotEmpty) {
        _commentsStream?.add(commentsOrdered.sublist(0, i).reversed.toList());
        index = i;
      }
    }
  }

  List<Comment> getOrderedComments() {
    List<Comment> result = [];
    commentsBloc.forEach((_, value) {
      if (value.lvl == 1) {
        result.add(value);
      }
    });
    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }

  int getNumberOfReplies(String commentUid) {
    Comment c = commentsBloc[commentUid]!;
    int count = 0;
    c.replies!.forEach((_, commentLvl2) {
      count++;
      if (commentLvl2.replies!.isNotEmpty) {
        commentLvl2.replies!.forEach((_, commentLvl3) {
          count++;
          if (commentLvl3.replies!.isNotEmpty) {
            commentLvl3.replies!.forEach((_, commentLvl4) {
              count++;
            });
          }
        });
      }
    });

    return count;
  }
}
