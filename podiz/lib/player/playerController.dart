import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'PlayerManager.dart';

enum PlayerAction { play, pause, forward, backward }

final playerControllerProvider =
    StateNotifierProvider<PlayerControler, PlayerAction?>((ref) {
  final manager = ref.watch(playerManagerProvider);
  return PlayerControler(playerManager: manager);
});

class PlayerControler extends StateNotifier<PlayerAction?> {
  final PlayerManager playerManager;
  PlayerControler({required this.playerManager}) : super(null);

  Future<void> play() async {
    state = PlayerAction.play;
    try {
      playerManager.resumePodcast();
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> pause() async {
    state = PlayerAction.pause;
    try {
      await playerManager.pausePodcast();
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> goForward() async {
    state = PlayerAction.forward;
    try {
      await playerManager.play30Up();
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> goBackward() async {
    state = PlayerAction.backward;
    try {
      await playerManager.play30Back();
    } catch (e) {
      print(e);
    }
    state = null;
  }
}
