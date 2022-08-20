import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

class PlayerTimeChip extends ConsumerWidget {
  final bool loading;
  final IconData? icon;
  final VoidCallback? onTap;

  const PlayerTimeChip({
    Key? key,
    this.loading = false,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerTime = ref.watch(playerSliderControllerProvider);
    return TimeChip(
      loading: loading,
      position: playerTime.position,
      icon: icon,
      color: Palette.pink,
      onTap: onTap,
    );
  }
}

class TimeChip extends StatelessWidget {
  final bool loading;
  final Duration position;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const TimeChip({
    Key? key,
    this.loading = false,
    required this.position,
    this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  String format(Duration duration) {
    final time = duration.toString().split('.').first;
    if (time.startsWith('0:')) return time.substring(2);
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const StadiumBorder(),
      color: color ?? Colors.black87,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => loading ? null : onTap?.call(),
        child: Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon!, size: kSmallIconSize),
              const SizedBox(width: 4),
              Text(
                format(position),
                style: context.textTheme.titleSmall!.copyWith(
                  color: Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
