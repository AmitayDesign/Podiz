import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/Podcast.dart';

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

  Future<void> play(Podcast podcast) async {
    state = PlayerAction.play;
    try {
      // playerManager.resumeEpisode(podcast);
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> pause(Podcast podcast) async {
    state = PlayerAction.pause;
    try {
      // playerManager.pauseEpisode();
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> goForward(Podcast podcast) async {
    state = PlayerAction.forward;
    try {
      playerManager.play30Up(podcast);
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> goBackward(Podcast podcast) async {
    state = PlayerAction.backward;
    try {
      playerManager.play30Back(podcast);
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print(e);
    }
    state = null;
  }
}
