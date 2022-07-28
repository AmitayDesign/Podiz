import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart';

class PinkProgress extends ConsumerStatefulWidget {
  PinkProgress({Key? key}) : super(key: key);

  @override
  ConsumerState<PinkProgress> createState() => _PinkProgressState();
}

class _PinkProgressState extends ConsumerState<PinkProgress> {
  Duration position = Duration.zero;
  StreamSubscription<Duration>? subscription;

  late Podcast podcast;

  @override
  void initState() {
    var player = ref.read(playerProvider);
    position = player.position;
    podcast = player.podcastPlaying!;

    subscription = player.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      padding: EdgeInsets.zero,
      width: kScreenWidth,
      lineHeight: 4.0,
      percent: position.inMilliseconds / podcast.duration_ms,
      backgroundColor: const Color(0xFFE5CEFF),
      progressColor: const Color(0xFFD74EFF),
    );
  }
}
