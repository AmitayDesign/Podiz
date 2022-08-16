import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';

final playerSliderControllerProvider =
    StateNotifierProvider.autoDispose<PlayerSliderController, int>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  // final time = ref.watch(playerTimeProvider).valueOrNull ?? 0;
  return PlayerSliderController(
    playerRepository: repository,
    // playerTime: time,
  );
});

//TODO remove logic from player slider and update TimeChip widget
class PlayerSliderController extends StateNotifier<int> {
  final PlayerRepository playerRepository;
  // final int playerTime;

  PlayerSliderController({
    required this.playerRepository,
    // required this.playerTime,
  }) : super(0);

  // bool updatesWithTime = true;
  // void decideTime() {
  //   return updatesWithTime ? playerTime :
  // }

  Future<void> seekTo(int seconds) => playerRepository.seekTo(seconds);
}
