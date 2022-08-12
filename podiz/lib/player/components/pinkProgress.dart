import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/providers.dart';

class PinkProgress extends ConsumerWidget {
  final int duration;
  const PinkProgress(this.duration, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position =
        ref.watch(playerPositionStreamProvider).valueOrNull ?? Duration.zero;
    //TODO load positon and on loading user LinearProgressIndicator
    return LinearPercentIndicator(
      padding: EdgeInsets.zero,
      width: kScreenWidth,
      lineHeight: 4.0,
      percent: position.inMilliseconds / duration,
      backgroundColor: const Color(0xFFE5CEFF),
      progressColor: const Color(0xFFD74EFF),
    );
  }
}
