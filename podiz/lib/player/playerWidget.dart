import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/pinkProgress.dart';
import 'package:podiz/player/components/pinkTimer.dart';
import 'package:podiz/player/playerController.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class PlayerWidget extends ConsumerWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stateProvider);
    final loadingAction = ref.watch(playerControllerProvider);
    return state.when(
      data: (s) {
        if (s == PlayerState.close) return Container();

        final podcast = ref.watch(playerpodcastFutureProvider);
        return podcast.when(
            error: (e, _) {
              print('playerWidget: ${e.toString()}');
              return SplashScreen.error();
            },
            loading: () => const LoadingAction(),
            data: (p) {
              final playerManager = ref.watch(playerManagerProvider);
              p = playerManager.playerBloc.podcastPlaying!;
              final action = s == PlayerState.play
                  ? PlayerAction.pause
                  : PlayerAction.play;
              final icon =
                  s == PlayerState.play ? Icons.pause : Icons.play_arrow;
              final onTap = s == PlayerState.play
                  ? () => ref.read(playerControllerProvider.notifier).pause(p)
                  : () => ref.read(playerControllerProvider.notifier).play(p);
              return Material(
                color: Palette.darkPurple,
                child: InkWell(
                  onTap: () => context.goNamed(
                    AppRoute.discussion.name,
                    params: {'episodeId': p.uid!},
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PinkProgress(p.duration_ms),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                        .goBackward(p)
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
                                        .goForward(p)
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
