import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/error_player.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/player_slider.dart';
import 'package:podiz/src/features/player/presentation/spotify_button.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:podiz/src/utils/string_zwsp.dart';

import 'skeleton_player.dart';

class Player extends ConsumerWidget {
  final bool extraBottomPadding;
  const Player({Key? key, this.extraBottomPadding = false}) : super(key: key);

  static const heightWithSpotify = height + 64; //! hardcoded
  static final extraHeightWithSpotify = extraHeight + 64; //! hardcoded

  static const height = 80.0; //! hardcoded
  static final extraHeight = height + (Platform.isIOS ? 16 : 0); //! hardcoded

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeValue = ref.watch(playerStateChangesProvider);
    final state = ref.watch(playerControllerProvider);
    return episodeValue.when(
      loading: () => SkeletonPlayer(extraBottomPadding),
      error: (e, _) => ErrorPlayer(extraBottomPadding),
      data: (episode) {
        if (episode == null) return const SizedBox.shrink();
        //! beep
        // filter comments based on player position
        // ref.listen(filteredCommentsProvider(episode.id), (_, __) {});
        // ref.listen<PlayerTime>(
        //   playerSliderControllerProvider,
        //   (_, playerTime) {
        //     final beep = ref
        //         .read(playerSliderControllerProvider.notifier)
        //         .updatesWithTime;
        //     ref
        //         .read(filteredCommentsProvider(episode.id).notifier)
        //         .updateComments(playerTime.position, beep);
        //   },
        // );
        //! beep
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpotifyButton(episode.id),
            Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: PlayerSlider.height / 2 + 2),
                  child: Material(
                    color: Palette.darkPurple,
                    child: InkWell(
                      onTap: () => context.pushNamed(
                        AppRoute.discussion.name,
                        params: {'episodeId': episode.id},
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 16, 12).add(
                          Platform.isIOS && extraBottomPadding
                              ? const EdgeInsets.only(bottom: 16)
                              : EdgeInsets.zero,
                        ),
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
                                      episode.name.useCorrectEllipsis(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            PlayerButton(
                              loading: state == PlayerControls.rewind,
                              onPressed: () => state != null
                                  ? null
                                  : ref
                                      .read(playerControllerProvider.notifier)
                                      .rewind(),
                              icon: const Icon(Icons.replay_30_rounded),
                            ),
                            episode.isPlaying
                                ? PlayerButton(
                                    loading: state == PlayerControls.pause,
                                    onPressed: () => state != null
                                        ? null
                                        : ref
                                            .read(playerControllerProvider
                                                .notifier)
                                            .pause(),
                                    icon: const Icon(Icons.pause_rounded),
                                  )
                                : PlayerButton(
                                    loading: state == PlayerControls.play,
                                    onPressed: () => state != null
                                        ? null
                                        : ref
                                            .read(playerControllerProvider
                                                .notifier)
                                            .play(episode.id),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                  ),
                            PlayerButton(
                              loading: state == PlayerControls.fastForward,
                              onPressed: () => state != null
                                  ? null
                                  : ref
                                      .read(playerControllerProvider.notifier)
                                      .fastForward(),
                              icon: const Icon(Icons.forward_30_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const PlayerSlider(),
              ],
            ),
          ],
        );
      },
    );
  }
}
