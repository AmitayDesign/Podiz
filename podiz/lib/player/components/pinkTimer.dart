import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/providers.dart';

class PinkTimer extends ConsumerStatefulWidget {
  PinkTimer({Key? key}) : super(key: key);

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
      child: Center(
        child: Text(
          timePlayerFormatter(position.inMilliseconds),
          style: discussionSnackPlay(),
        ),
      ),
      width: 64,
      height: 23,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFFD74EFF)),
    );
  }
}
