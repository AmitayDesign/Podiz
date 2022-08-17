import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/player_time.dart';

final playerSliderControllerProvider =
    StateNotifierProvider.autoDispose<PlayerSliderController, PlayerTime>(
        (ref) {
  final repository = ref.watch(playerRepositoryProvider);
  final playerTimeStream = ref.watch(playerTimeStreamProvider.stream);
  return PlayerSliderController(
    playerRepository: repository,
    playerTimeStream: playerTimeStream,
  );
});

//TODO remove logic from player slider and update PlayerTimeChip widget
class PlayerSliderController extends StateNotifier<PlayerTime> {
  static PlayerTime? cachedPlayerTime;

  final PlayerRepository playerRepository;
  final Stream<PlayerTime> playerTimeStream;
  bool updatesWithTime = true;

  PlayerSliderController({
    required this.playerRepository,
    required this.playerTimeStream,
  }) : super(cachedPlayerTime ?? PlayerTime.zero) {
    listenToPlayerTime();
  }

  late final StreamSubscription sub;
  void listenToPlayerTime() {
    sub = playerTimeStream.listen((playerTime) {
      if (updatesWithTime) state = playerTime;
    });
  }

  set position(int position) =>
      state = PlayerTime(position: position, duration: state.duration);

  Future<void> seekTo(int seconds) => playerRepository.seekTo(seconds);

  @override
  void dispose() {
    sub.cancel();
    cachedPlayerTime = state;
    super.dispose();
  }
}
