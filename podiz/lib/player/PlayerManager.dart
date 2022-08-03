import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final playerManagerProvider = Provider<PlayerManager>(
  (ref) => PlayerManager(ref.read),
);

class PlayerManager {
  final Reader _read;

  AuthManager get authManager => _read(authManagerProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);
  get playerStream => _read(playerStreamProvider);

  final _playerStream = BehaviorSubject<Player>();
  Stream<Player> get player => _playerStream.stream;

  Sink<Map<String, dynamic>> get playerSink => _playerSinkController;
  final _playerSinkController = StreamController<Map<String, dynamic>>();

  Player playerBloc = Player();

  BehaviorSubject<List<Comment>>? _commentsStream;

  Stream<List<Comment>> get comments => _commentsStream!.stream;

  StreamSubscription<QuerySnapshot>? commentsStreamSubscription;

  Map<String, Comment> commentsBloc = {}; //change this

  List<Comment> commentsOrdered = [];

  int index = 0;

  bool firstTime = true;

  PlayerManager(this._read) {
    _playerStream.add(playerBloc);
    String userUid = authManager.userBloc!.uid!;

    _playerSinkController.stream.listen((event) async {
      String key = event.keys.first;
      if (key == "pause") {
        await playerBloc.pauseEpisode(userUid);
      } else if (key == "play") {
        await playerBloc.playEpisode(
            event[key]["episode"], userUid, event[key]["position"]);
      } else if (key == "close") {
        playerBloc.closePlayer();
      }
      _playerStream.add(playerBloc);
    });
  }

  void playEpisode(Podcast podcast, int position) {
    print(podcast.uid);
    playerSink.add({
      "play": {"episode": podcast, "position": position}
    });
    authManager.updateLastListened(podcast.uid!);
    setUpDiscussionPageStream(podcast.uid!);
  }

  void pauseEpisode() {
    playerSink.add({"pause": true});
  }

  void resumeEpisode(Podcast podcast) {
    playerSink.add({
      "play": {
        "episode": podcast,
        "position": playerBloc.timer.position.inMilliseconds
      }
    });
  }

  void play30Back(Podcast podcast) {
    Duration pos = playerBloc.timer.position;
    if (pos.inMilliseconds < Duration(seconds: 30).inMilliseconds) {
      print("entrei");
      pos = Duration.zero;
    } else {
      pos = Duration(
          milliseconds:
              pos.inMilliseconds - Duration(seconds: 30).inMilliseconds);
    }
    playerSink.add({
      "play": {"episode": podcast, "position": pos.inMilliseconds}
    });
  }

  void play30Up(Podcast podcast) {
    Duration pos = playerBloc.timer.position;
    Duration dur = playerBloc.timer.duration;
    if ((pos.inMilliseconds + Duration(seconds: 30).inMilliseconds) >
        dur.inMilliseconds) {
      pos = dur;
    } else {
      pos = Duration(
          milliseconds:
              pos.inMilliseconds + Duration(seconds: 30).inMilliseconds);
    }
    playerSink.add({
      "play": {"episode": podcast, "position": pos.inMilliseconds}
    });
  }

  setUpDiscussionPageStream(String podcastUid) async {
    if (!firstTime) {
      await commentsStreamSubscription!.cancel();
      await _commentsStream!.close();
      commentsBloc = {};
      commentsOrdered = [];
    }
    index = 0;
    firstTime = false;
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
        // else if (commentChange.type == DocumentChangeType.modified) {
        //   await editCommentToBloc(commentChange.doc);
        // }
      }
      commentsOrdered = getOrderedComments();
      _commentsStream!.add([]);
    });
  }

  addCommentToBloc(Doc doc) {
    Comment comment = Comment.fromJson(doc.data()!);
    comment.id = doc.id;
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

  showComments(int time) {
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
