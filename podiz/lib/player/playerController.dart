import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';

enum PlayerAction { play, pause, forward, backward }

final playerControllerProvider =
    StateNotifierProvider<PlayerControler, PlayerAction?>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  return PlayerControler(playerRepository: repository);
});

class PlayerControler extends StateNotifier<PlayerAction?> {
  final PlayerRepository playerRepository;
  PlayerControler({required this.playerRepository}) : super(null);

  Future<void> play() async {
    state = PlayerAction.play;
    try {
      await playerRepository.resume();
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> pause() async {
    state = PlayerAction.pause;
    try {
      await playerRepository.pause();
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> goForward() async {
    state = PlayerAction.forward;
    try {
      await playerRepository.fastForward();
    } catch (e) {
      print(e);
    }
    state = null;
  }

  Future<void> goBackward() async {
    state = PlayerAction.backward;
    try {
      await playerRepository.rewind();
    } catch (e) {
      print(e);
    }
    state = null;
  }
}
