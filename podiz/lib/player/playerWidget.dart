import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/player/components/pinkProgress.dart';
import 'package:podiz/player/playerController.dart';
import 'package:podiz/providers.dart';

import 'components/pinkTimer.dart';

class PlayerWidget extends ConsumerWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerStreamProvider);
    final loadingAction = ref.watch(playerControllerProvider);
    return state.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (player) {
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
              params: {'episodeId': player.podcast.uid!},
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PinkProgress(player.duration.inMilliseconds),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: PinkTimer(),
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
