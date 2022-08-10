import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/pinkProgress.dart';
import 'package:podiz/player/components/pinkTimer.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class PlayerWidget extends ConsumerWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("building");
    final state = ref.watch(stateProvider);
    return state.maybeWhen(
      data: (s) {
        if (s == PlayerState.close) return Container();

        final icon = s == PlayerState.play ? Icons.stop : Icons.play_arrow;

        final podcast = ref.watch(podcastProvider);
        return podcast.maybeWhen(
            orElse: () => SplashScreen.error(),
            loading: () => const CircularProgressIndicator(),
            data: (p) {
              final playerManager = ref.watch(playerManagerProvider);
              p = playerManager.playerBloc.podcastPlaying!;
              final onTap = s == PlayerState.play
                  ? () => playerManager.pauseEpisode()
                  : () => playerManager.resumeEpisode(p);
              return InkWell(
                onTap: () => context.pushNamed(
                  AppRoute.discussion.name,
                  params: {'showId': p.uid!},
                ),
                child: Column(
                  children: [
                    PinkProgress(p.duration_ms),
                    Container(
                      height: 100,
                      color: const Color(0xFF3E0979),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            PodcastAvatar(imageUrl: p.image_url, size: 52),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: kScreenWidth - (14 + 52 + 8 + 8 + 80 + 14),
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
                                      child: Text(p.name,
                                          style: discussionAppBarInsights(),
                                          maxLines: 1)),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => playerManager.play30Back(p),
                                icon: const Icon(
                                  Icons.rotate_90_degrees_ccw_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(icon),
                                onPressed: onTap,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => playerManager.play30Up(p),
                                icon: const Icon(
                                  Icons.rotate_90_degrees_cw_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
      orElse: () => SplashScreen.error(),
    );
  }
}
