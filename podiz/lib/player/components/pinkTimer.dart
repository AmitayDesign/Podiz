import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/providers.dart';

class PinkTimer extends ConsumerWidget {
  const PinkTimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position =
        ref.watch(playerPositionStreamProvider).valueOrNull ?? Duration.zero;
    return Container(
      width: 64,
      height: 23,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFFD74EFF)),
      child: Center(
        child: Text(
          timePlayerFormatter(position.inMilliseconds),
          style: context.textTheme.titleMedium,
        ),
      ),
    );
  }
}
