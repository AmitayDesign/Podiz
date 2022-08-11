import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
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
    final state = ref.watch(stateProvider);
    return state.when(
      data: (s) {
        if (s == PlayerState.close) return Container();

        final icon = s == PlayerState.play ? Icons.stop : Icons.play_arrow;

        final podcast = ref.watch(playerPodcastProvider);
        return podcast.when(
            error: (e, _) {
              print('playerWidget: ${e.toString()}');
              return SplashScreen.error();
            },
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
                  params: {'showId': p.show_uri},
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: PinkTimer(),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      p.name,
                                      style: context.textTheme.bodyMedium,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.all(8),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => playerManager.play30Back(p),
                                icon: const Icon(
                                  Icons.rotate_90_degrees_ccw_outlined,
                                ),
                              ),
                            ),
                            // const SizedBox(width: 18),
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.all(8),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(icon),
                                onPressed: onTap,
                              ),
                            ),
                            // const SizedBox(width: 18),
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.all(8),
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
      error: (e, _) {
        print('playerWidget: ${e.toString()}');
        return SplashScreen.error();
      },
      loading: () => SplashScreen(),
    );
  }
}
