import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/player/PlayerManager.dart';

class ButtonPlay extends ConsumerWidget {
  Podcast podcast;
  int time;

  ButtonPlay(this.podcast, this.time, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerManager playerManager = ref.read(playerManagerProvider);
    return InkWell(
      onTap: () {
        if (podcast != null) {
          playerManager.playEpisode(podcast, time);
        }
      },
      child: Container(
        width: 76,
        height: 23,
        decoration: BoxDecoration(
          color: Color(0xFF040404),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const Icon(
            Icons.play_arrow,
            color: Color(0xE6FFFFFF),
            size: 20,
          ),
          Text(
            timePlayerFormatter(time),
            style: discussionCardPlay(),
          ),
        ]),
      ),
    );
  }
}
