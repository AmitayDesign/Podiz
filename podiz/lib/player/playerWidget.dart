import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/player/components/pinkProgress.dart';
import 'package:podiz/player/playerController.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';

import 'components/pinkTimer.dart';

class PlayerWidget extends ConsumerWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerValue = ref.watch(playerStateChangesProvider);
    // print(playerValue.valueOrNull?.playbackPosition);
    final loadingAction = ref.watch(playerControllerProvider);
    return playerValue.when(
      error: (e, _) {
        print(e);
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      data: (player) {
        print('XXX ${player?.episode.name}');
        print('XXX ${player?.isPlaying}');
        if (player == null) return const SizedBox.shrink();
        final action =
            player.isPlaying ? PlayerAction.pause : PlayerAction.play;
        final icon = player.isPlaying ? Icons.pause : Icons.play_arrow;
        final onTap = player.isPlaying
            ? () => ref.read(playerControllerProvider.notifier).pause()
            : () => ref.read(playerControllerProvider.notifier).play();
        return Material(
          color: Palette.darkPurple,
          child: InkWell(
            onTap: () => context.goNamed(
              AppRoute.discussion.name,
              params: {'episodeId': player.episode.id},
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PinkProgress(player.episode.duration),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PodcastAvatar(
                        imageUrl: player.episode.imageUrl,
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
                                player.episode.name,
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
                          onPressed: loadingAction == null
                              ? () => ref
                                  .read(playerControllerProvider.notifier)
                                  .goBackward()
                              : null,
                          icon: loadingAction == PlayerAction.backward
                              ? const LoadingAction()
                              : const Icon(Icons.replay_30),
                        ),
                      ),
                      // const SizedBox(width: 18),
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: loadingAction == null ? onTap : null,
                          icon: loadingAction == action
                              ? const LoadingAction()
                              : Icon(icon),
                        ),
                      ),
                      // const SizedBox(width: 18),
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: loadingAction == null
                              ? () => ref
                                  .read(playerControllerProvider.notifier)
                                  .goForward()
                              : null,
                          icon: loadingAction == PlayerAction.forward
                              ? const LoadingAction()
                              : const Icon(Icons.forward_30),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LoadingAction extends StatelessWidget {
  const LoadingAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: context.theme.disabledColor,
      ),
    );
  }
}
