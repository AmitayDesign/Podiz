import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundpool/soundpool.dart';

final beepControllerProvider = Provider<BeepController>((ref) {
  final controller = BeepController();
  ref.onDispose(controller.dispose);
  return controller;
});

class BeepController {
  late final int _soundId;
  late final Soundpool _soundpool;

  Future<void> init() async {
    _soundpool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.notification),
    );
    _soundId = await rootBundle
        .load('assets/sounds/graceful.mp3')
        .then(_soundpool.load);
  }

  void play() => _soundpool.play(_soundId);

  void dispose() => _soundpool.dispose();
}
