import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/error_player.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/player_slider.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';

import 'skeleton_player.dart';

class Player extends ConsumerWidget {
  const Player({Key? key}) : super(key: key);

  static const height = 80.0; //! hardcoded

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeValue = ref.watch(playerStateChangesProvider);
    final state = ref.watch(playerControllerProvider);
    return episodeValue.when(
      loading: () => const SkeletonPlayer(),
      error: (e, _) => const ErrorPlayer(),
      data: (episode) {
        if (episode == null) return const SizedBox.shrink();
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: PlayerSlider.height / 2 + 2),
              child: Material(
                color: Palette.darkPurple,
                child: InkWell(
                  onTap: () => context.goNamed(
                    AppRoute.discussion.name,
                    params: {'episodeId': episode.id},
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
                    child: Row(
                      children: [
                        PodcastAvatar(imageUrl: episode.imageUrl, size: 52),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PlayerTimeChip(),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => context.goNamed(
                                  AppRoute.podcast.name,
                                  params: {'podcastId': episode.showId},
                                ),
                                child: Text(
                                  episode.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        PlayerButton(
                          loading: state.isLoading,
                          onPressed: ref
                              .read(playerControllerProvider.notifier)
                              .rewind,
                          icon: const Icon(Icons.replay_30),
                        ),
                        episode.isPlaying
                            ? PlayerButton(
                                loading: state.isLoading,
                                onPressed: ref
                                    .read(playerControllerProvider.notifier)
                                    .pause,
                                icon: const Icon(Icons.pause),
                              )
                            : PlayerButton(
                                loading: state.isLoading,
                                onPressed: () => ref
                                    .read(playerControllerProvider.notifier)
                                    .play(episode.id),
                                icon: const Icon(Icons.play_arrow),
                              ),
                        PlayerButton(
                          loading: state.isLoading,
                          onPressed: ref
                              .read(playerControllerProvider.notifier)
                              .fastForward,
                          icon: const Icon(Icons.forward_30),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const PlayerSlider(),
          ],
        );
      },
    );
  }
}
