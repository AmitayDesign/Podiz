import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';

enum PlayerControls { play, pause, fastForward, rewind }

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerControls?>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  return PlayerController(playerRepository: repository);
});

class PlayerController extends StateNotifier<PlayerControls?> {
  final PlayerRepository playerRepository;
  PlayerController({required this.playerRepository}) : super(null);

  Future<void> play(String episodeId) async {
    state = PlayerControls.play;
    await playerRepository.resume(episodeId);
    state = null;
  }

  Future<void> pause() async {
    state = PlayerControls.pause;
    await playerRepository.pause();
    state = null;
  }

  Future<void> fastForward() async {
    state = PlayerControls.fastForward;
    await playerRepository.fastForward();
    state = null;
  }

  Future<void> rewind() async {
    state = PlayerControls.rewind;
    await playerRepository.rewind();
    state = null;
  }
}
