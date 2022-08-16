import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/theme/palette.dart';

class TimeChip extends ConsumerWidget {
  final IconData? icon;
  final VoidCallback? onTap;
  const TimeChip({Key? key, this.icon, this.onTap}) : super(key: key);

  String timeFromMilliseconds(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final time = duration.toString().split('.').first;
    if (time.startsWith('0:')) return time.substring(2);
    return time;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerTime = ref.watch(playerTimeStreamProvider).valueOrNull;
    final position = playerTime?.position ?? 0;
    return Material(
      shape: const StadiumBorder(),
      color: Palette.pink,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon!, size: kSmallIconSize),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  timeFromMilliseconds(position),
                  style: context.textTheme.titleSmall!.copyWith(
                    color: Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
