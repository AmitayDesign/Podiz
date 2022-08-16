import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/theme/palette.dart';

class ButtonPlay extends ConsumerWidget {
  final Podcast podcast;
  final int time;

  const ButtonPlay(this.podcast, this.time, {Key? key}) : super(key: key);

  String timeFromMilliseconds(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final time = duration.toString().split('.').first;
    if (time.startsWith('0:')) return time.substring(2);
    return time;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerManager = ref.watch(playerRepositoryProvider);
    return InkWell(
      onTap: () {
        // TODO what if the playingnpodcast is different
        playerManager.play(podcast.uid!, time - 10000);
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
              timeFromMilliseconds(time),
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
