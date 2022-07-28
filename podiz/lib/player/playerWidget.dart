import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/player/components/pinkProgress.dart';
import 'package:podiz/player/components/pinkTimer.dart';
import 'package:podiz/player/screens/discussionPage.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class PlayerWidget extends ConsumerWidget {
  PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    print("building");
    final state = ref.watch(stateProvider);
    return state.maybeWhen(
      data: (s) {
        if(s == PlayerState.close) return Container();
        final podcast = ref.read(playerProvider).podcastPlaying!;
        final icon = s == PlayerState.play ? Icons.stop : Icons.play_arrow;
        final onTap = s == PlayerState.play
            ? () => ref.read(playerManagerProvider).pauseEpisode()
            : () => ref.read(playerManagerProvider).resumeEpisode();
        return InkWell(
          onTap: () => Navigator.pushNamed(context, DiscussionPage.route),
          child: Column(
            children: [
              PinkProgress(),
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
                              child: PinkTimer(),
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
      },
      orElse: () => SplashScreen.error(),
    );
  }
}
