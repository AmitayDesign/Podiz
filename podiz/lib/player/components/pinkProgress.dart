import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';

class PinkProgress extends ConsumerWidget {
  final int duration;
  const PinkProgress(this.duration, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerTime = ref.watch(playerTimeStreamProvider).valueOrNull;
    final position = playerTime?.position ?? 0;
    //TODO load positon and on loading user LinearProgressIndicator
    //TODO animate percent
    return LinearPercentIndicator(
      padding: EdgeInsets.zero,
      width: kScreenWidth,
      lineHeight: 4.0,
      percent: position / duration,
      backgroundColor: const Color(0xFFE5CEFF),
      progressColor: const Color(0xFFD74EFF),
    );
  }
}
