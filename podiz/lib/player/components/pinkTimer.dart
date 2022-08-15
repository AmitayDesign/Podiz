import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/theme/palette.dart';

class PinkTimer extends ConsumerWidget {
  final Widget? icon;
  final VoidCallback? onPressed;
  const PinkTimer({Key? key, this.icon, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(playerTimeProvider).valueOrNull ?? 0;
    return Container(
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Palette.pink,
      ),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: icon!,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Text(
                  timePlayerFormatter(position),
                  style: context.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
