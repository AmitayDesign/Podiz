import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundpool/soundpool.dart';

final beepControllerProvider = Provider<BeepController>((ref) {
  final controller = BeepController();
  ref.onDispose(controller.dispose);
  return controller;
});

class BeepController {
  int? _soundId;
  final _soundpool = Soundpool.fromOptions(
    options: const SoundpoolOptions(streamType: StreamType.notification),
  );

  BeepController() {
    _loadSound();
  }

  void _loadSound() async {
    _soundId = await rootBundle
        .load('assets/sounds/graceful.mp3')
        .then(_soundpool.load);
  }

  void dispose() {
    _soundpool.dispose();
  }

  void play() {
    if (_soundId != null) _soundpool.play(_soundId!);
  }
}
