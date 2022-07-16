import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/player/screens/discussionPage.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';

class PlayerWidget extends ConsumerStatefulWidget {
  Player player;
  PlayerWidget(this.player, {Key? key}) : super(key: key);

  @override
  ConsumerState<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends ConsumerState<PlayerWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final podcast = widget.player.podcastPlaying!;
    final playerState = widget.player.playingState;

    final icon =
        playerState == PlayerState.play ? Icons.stop : Icons.play_arrow;

    final onTap = playerState == PlayerState.play
        ? () => ref.read(playerManagerProvider).pauseEpisode()
        : () => ref
            .read(playerManagerProvider)
            .playEpisode(widget.player.podcastPlaying!);

    return InkWell(
      onTap: () => Navigator.pushNamed(context, DiscussionPage.route, arguments: podcast),
      child: Column(
        children: [
          const LinearProgressIndicator(
            backgroundColor: Color(0xFFE5CEFF),
            color: Color(0xFFD74EFF),
            minHeight: 4,
          ),
          Container(
            height: 100,
            color: const Color(0xFF3E0979),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PodcastAvatar(imageUrl: podcast.image_url, size: 52),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: kScreenWidth - (14 + 52 + 8 + 8 + 100 + 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Center(
                              child: Text(
                                  timePlayerFormatter(podcast.duration_ms),
                                  style: discussionCardPlay()),
                            ),
                            width: 57,
                            height: 23,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color(0xFFD74EFF)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(podcast.name,
                                style: discussionAppBarInsights(),
                                maxLines: 1)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(
                          Icons.rotate_90_degrees_ccw_outlined,
                          size: 25,
                        ),
                        IconButton(
                          icon: Icon(icon),
                          onPressed: onTap,
                          iconSize: 25,
                        ),
                        const Icon(
                          Icons.rotate_90_degrees_cw_outlined,
                          size: 25,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
