import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Comment.dart';
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

  PlayerManager(this._read);

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
    print(10);
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
