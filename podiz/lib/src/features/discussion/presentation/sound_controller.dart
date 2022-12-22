import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundpool/soundpool.dart';

final beepControllerProvider = Provider<BeepController>(
  // * Override this in the main method
  (ref) {
    throw UnimplementedError();
  },
);

class BeepController {
  final int _soundId;
  final Soundpool _soundpool;

  BeepController(this._soundpool, this._soundId);

  static Future<BeepController> get instance async {
    final soundpool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.notification),
    );
    final soundId = await rootBundle
        .load('assets/sounds/graceful.mp3')
        .then(soundpool.load);
    return BeepController(soundpool, soundId);
  }

  void play() => _soundpool.play(_soundId);

  // TODO how to dispose with override?
  void dispose() {
    _soundpool.dispose();
  }
}
