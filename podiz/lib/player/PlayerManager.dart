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

  List<Comment> commentsBloc = [];

  bool firstTime = true;

  PlayerManager(this._read) {
    _playerStream.add(playerBloc);
    String userUid = authManager.userBloc!.uid!;

    _playerSinkController.stream.listen((event) async {
      String key = event.keys.first;
      if (key == "pause") {
        await playerBloc.pauseEpisode(userUid);
      } else if (key == "play") {
        await playerBloc.playEpisode(event[key]["episode"], userUid);
      } else if (key == "resume") {
        await playerBloc.resumeEpisode(userUid);
      } else if (key == "close") {
        playerBloc.closePlayer();
      }
      _playerStream.add(playerBloc);
    });
  }

  setUpDiscussionPageStream(String podcastUid) async {
    if (!firstTime) {
      await commentsStreamSubscription!.cancel();
      await _commentsStream!.close();
      commentsBloc = [];
    }
    firstTime = false;
    _commentsStream = BehaviorSubject<List<Comment>>();
    commentsStreamSubscription = firestore
        .collection("podcasts")
        .doc(podcastUid)
        .collection("comments")
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
      _commentsStream!.add(commentsBloc);
    });
  }

  addCommentToBloc(Doc doc) {
    Comment comment = Comment.fromJson(doc.data()!);
    comment.id = doc.id;
    commentsBloc.add(comment);
  }

  void playEpisode(Podcast podcast) {
    playerSink.add({
      "play": {"episode": podcast}
    });
    authManager.updateLastListened(podcast.uid!);
    setUpDiscussionPageStream(podcast.uid!);
  }

  void pauseEpisode() {
    playerSink.add({"pause": true});
  }

  void resumeEpisode() {
    playerSink.add({"resume": true});
  }

  List<Comment> showComments(int time) {
    List<Comment> result = [];
    commentsBloc.map((c) {
      if (c.time < time) result.add(c);
    });
    return result;
  }
}
