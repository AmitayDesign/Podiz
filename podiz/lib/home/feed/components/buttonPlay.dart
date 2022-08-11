import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/player/PlayerManager.dart';

class ButtonPlay extends ConsumerWidget {
  final Podcast podcast;
  final int time;

  const ButtonPlay(this.podcast, this.time, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerManager = ref.watch(playerManagerProvider);
    return InkWell(
      onTap: () {
        playerManager.playEpisode(podcast, time);
      },
      child: Container(
        width: 76,
        height: 23,
        decoration: BoxDecoration(
          color: const Color(0xFF040404),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(
              Icons.play_arrow,
              color: Palette.white90,
              size: 20,
            ),
            Text(
              timePlayerFormatter(time),
              style: context.textTheme.titleMedium!.copyWith(
                color: Palette.white90,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
