import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';

final playerControllerProvider =
    StateNotifierProvider<PlayerController, AsyncValue>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  return PlayerController(playerRepository: repository);
});

class PlayerController extends StateNotifier<AsyncValue> {
  final PlayerRepository playerRepository;
  PlayerController({required this.playerRepository})
      : super(const AsyncValue.data(null));

  Future<void> play(String episodeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => playerRepository.resume(episodeId));
  }

  Future<void> pause() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => playerRepository.pause());
  }

  Future<void> fastForward() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => playerRepository.fastForward());
  }

  Future<void> rewind() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => playerRepository.rewind());
  }
}
