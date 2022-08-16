import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/theme/palette.dart';

import 'player_slider_controller.dart';

class PlayerSlider extends ConsumerStatefulWidget {
  const PlayerSlider({Key? key}) : super(key: key);

  @override
  ConsumerState<PlayerSlider> createState() => _PlayerSliderState();
}

class _PlayerSliderState extends ConsumerState<PlayerSlider> {
  final height = 4.0;
  double sliderValue = 0;
  bool updatesWithTime = true;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final playerTime = ref.watch(playerTimeStreamProvider).valueOrNull;
    final position = playerTime?.position ?? 0;
    final duration = playerTime?.duration ?? 1;

    final timeInSeconds = position ~/ 1000;
    final durationInSeconds = duration ~/ 1000;
    if (updatesWithTime) {
      sliderValue = (timeInSeconds).toDouble();
    }
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: height,
        inactiveTrackColor: Palette.lightPink,
        activeTrackColor: Palette.pink,
        thumbColor: Palette.pink,
        trackShape: CustomTrackShape(),
        thumbShape:
            RoundSliderThumbShape(enabledThumbRadius: isPressed ? 8 : 4),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: SizedBox(
        height: height,
        child: Slider(
          value: sliderValue,
          min: 0,
          max: durationInSeconds.toDouble(),
          // enables ui to update
          onChangeStart: (_) => setState(() {
            updatesWithTime = false;
            isPressed = true;
          }),
          // update ui
          onChanged: (value) => setState(() => sliderValue = value),
          // update player time
          onChangeEnd: (time) async {
            ref
                .read(playerSliderControllerProvider.notifier)
                .seekTo(time.toInt());
            setState(() => isPressed = false);
            await Future.delayed(const Duration(seconds: 2));
            updatesWithTime = true;
          },
          label: timeInSeconds.toString(),
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
