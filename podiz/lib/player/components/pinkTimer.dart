import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/objects/user/Player.dart';

class PinkTimer extends StatefulWidget {
  Player player;
  PinkTimer(this.player, {Key? key}) : super(key: key);

  @override
  State<PinkTimer> createState() => _PinkTimerState();
}

class _PinkTimerState extends State<PinkTimer> {
  Duration position = Duration.zero;
  StreamSubscription<Duration>? subscription;

  @override
  void initState() {
    position = widget.player.position;
    subscription = widget.player.onAudioPositionChanged.listen(
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
          timePlayerFormatter(widget.player.position.inMilliseconds),
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
