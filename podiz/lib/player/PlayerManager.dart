import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/AuthManager.dart';
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

  get playerStream => _read(playerStreamProvider);

  final _playerStream = BehaviorSubject<Player>();
  Stream<Player> get player => _playerStream.stream;

  Sink<Map<String, dynamic>> get playerSink => _playerSinkController;
  final _playerSinkController = StreamController<Map<String, dynamic>>();
  Player playerBloc = Player();

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

  void playEpisode(Podcast podcast) {
    playerSink.add({
      "play": {"episode": podcast}
    });
    authManager.updateLastListened(podcast.uid!);
  }

  void pauseEpisode() {
    playerSink.add({"pause": true});
  }
}
