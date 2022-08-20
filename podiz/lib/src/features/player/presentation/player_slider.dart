import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/theme/palette.dart';

import 'player_slider_controller.dart';

class PlayerSlider extends ConsumerStatefulWidget {
  const PlayerSlider({Key? key}) : super(key: key);
  static const height = 24;

  @override
  ConsumerState<PlayerSlider> createState() => _PlayerSliderState();
}

class _PlayerSliderState extends ConsumerState<PlayerSlider> {
  bool isPressed = false;

  void enableSliderUpdates(_) {
    setState(() => isPressed = true);
    ref.read(playerSliderControllerProvider.notifier).updatesWithTime = false;
  }

  void updateSlider(double timeInMilliseconds) {
    ref.read(playerSliderControllerProvider.notifier).position =
        Duration(milliseconds: timeInMilliseconds.toInt());
  }

  void updatePlayerTime(double timeInMilliseconds) async {
    ref
        .read(playerSliderControllerProvider.notifier)
        .seekTo(Duration(milliseconds: timeInMilliseconds.toInt()));
    setState(() => isPressed = false);
    //TODO find a way to wait precisely
    await Future.delayed(const Duration(seconds: 2));
    ref.read(playerSliderControllerProvider.notifier).updatesWithTime = true;
  }

  @override
  Widget build(BuildContext context) {
    final playerTime = ref.watch(playerSliderControllerProvider);
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        inactiveTrackColor: Palette.lightPink,
        activeTrackColor: Palette.pink,
        thumbColor: Palette.pink,
        trackShape: CustomTrackShape(),
        //TODO make interactive area bigger
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: isPressed ? 8 : 4,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: PlayerSlider.height / 2,
        ),
      ),
      child: Slider(
        value: playerTime.position.inMilliseconds.toDouble(),
        min: 0,
        max: playerTime.duration.inMilliseconds.toDouble(),
        onChangeStart: enableSliderUpdates,
        onChanged: updateSlider,
        onChangeEnd: updatePlayerTime,
      ),
    );
  }
}

class CustomTrackShape extends RectangularSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final availableHeight = parentBox.size.height;
    final height = sliderTheme.trackHeight!;
    final width = parentBox.size.width;
    final top = (availableHeight - height) / 2;
    return Rect.fromLTWH(0, top, width, height);
  }
}
