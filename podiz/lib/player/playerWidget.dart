import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/pinkProgress.dart';
import 'package:podiz/player/components/pinkTimer.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class PlayerWidget extends ConsumerWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerManager = ref.watch(playerManagerProvider);
    final playerValue = ref.watch(playerStreamProvider);
    return playerValue.when(
      error: (e, _) {
        print('playerWidget: ${e.toString()}');
        return SplashScreen.error();
      },
      loading: () => SplashScreen(),
      data: (player) {
        if (player == null) return Container();
        final icon = player.isPlaying ? Icons.stop : Icons.play_arrow;
        final onTap = player.isPlaying
            ? () => playerManager.pausePodcast()
            : () => playerManager.resumePodcast();
        return InkWell(
          onTap: () => context.goNamed(
            AppRoute.discussion.name,
            params: {'episodeId': player.podcast.uid!},
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinkProgress(player.podcast.duration_ms),
              Container(
                height: 100,
                color: const Color(0xFF3E0979),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PodcastAvatar(
                        imageUrl: player.podcast.image_url,
                        size: 52,
                      ),
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
                                player.podcast.name,
                                style: context.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                          onPressed: () => playerManager.play30Back(),
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
                          onPressed: () => playerManager.play30Up(),
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
      },
    );
  }
}
