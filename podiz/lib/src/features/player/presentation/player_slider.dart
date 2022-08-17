import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/theme/palette.dart';

import 'player_slider_controller.dart';

class PlayerSlider extends ConsumerStatefulWidget {
  const PlayerSlider({Key? key}) : super(key: key);

  @override
  ConsumerState<PlayerSlider> createState() => _PlayerSliderState();
}

class _PlayerSliderState extends ConsumerState<PlayerSlider> {
  final height = 4.0;
  bool isPressed = false;

  void enableSliderUpdates(_) {
    setState(() => isPressed = true);
    ref.read(playerSliderControllerProvider.notifier).updatesWithTime = false;
  }

  void updateSlider(double time) {
    ref.read(playerSliderControllerProvider.notifier).position = time.toInt();
  }

  void updatePlayerTime(double time) async {
    ref.read(playerSliderControllerProvider.notifier).seekTo(time.toInt());
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
        trackHeight: height,
        inactiveTrackColor: Palette.lightPink,
        activeTrackColor: Palette.pink,
        thumbColor: Palette.pink,
        trackShape: CustomTrackShape(),
        //TODO make interactive area bigger
        thumbShape:
            RoundSliderThumbShape(enabledThumbRadius: isPressed ? 8 : 4),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: SizedBox(
        height: height,
        child: Slider(
          value: playerTime.position.toDouble(),
          min: 0,
          max: playerTime.duration.toDouble(),
          onChangeStart: enableSliderUpdates,
          onChanged: updateSlider,
          onChangeEnd: updatePlayerTime,
        ),
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
    final height = sliderTheme.trackHeight!;
    final width = parentBox.size.width;
    return Rect.fromLTWH(0, 0, width, height);
  }
}
