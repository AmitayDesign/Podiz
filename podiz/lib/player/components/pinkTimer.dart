import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/providers.dart';

class PinkTimer extends ConsumerStatefulWidget {
  final Widget? icon;
  final VoidCallback? onPressed;
  const PinkTimer({Key? key, this.icon, this.onPressed}) : super(key: key);

  @override
  ConsumerState<PinkTimer> createState() => _PinkTimerState();
}

class _PinkTimerState extends ConsumerState<PinkTimer> {
  Duration position = Duration.zero;
  StreamSubscription<Duration>? subscription;

  @override
  void initState() {
    Player player = ref.read(playerProvider);
    position = player.timer.position;
    subscription = player.timer.onAudioPositionChanged.listen(
      (newPosition) {
        setState(() {
          position = newPosition;
        });
      },
      onError: (_) => subscription!.cancel(),
      cancelOnError: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Palette.pink,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: widget.icon!,
            ),
          SizedBox(
            width: 48,
            child: Center(
              child: Text(
                timePlayerFormatter(position.inMilliseconds),
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
