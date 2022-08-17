import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/discussion/presentation/comment_sheet_content.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/palette.dart';

class DiscussionSheet extends ConsumerWidget {
  const DiscussionSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episode = ref.watch(playerStateChangesProvider).valueOrNull!;
    final state = ref.watch(playerControllerProvider);
    return Material(
      color: Palette.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kBorderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommentSheetContent(
              onSend: () {
                // ref.read(authManagerProvider).doComment(
                //       commentController.text,
                //       episodeId,
                //       ref.read(playerTimeStreamProvider).value!.position,
                //     );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Row(
                children: [
                  Text(
                    "${episode.userIdsWatching.length - 1} listening with you"
                        .hardcoded,
                    style: context.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  PlayerButton(
                    loading: state.isLoading,
                    onPressed:
                        ref.read(playerControllerProvider.notifier).rewind,
                    icon: const Icon(Icons.replay_30),
                  ),
                  episode.isPlaying
                      ? PlayerTimeChip(
                          loading: state.isLoading,
                          onTap:
                              ref.read(playerControllerProvider.notifier).pause,
                          icon: Icons.pause,
                        )
                      : PlayerTimeChip(
                          loading: state.isLoading,
                          onTap: () => ref
                              .read(playerControllerProvider.notifier)
                              .play(episode.id),
                          icon: Icons.play_arrow,
                        ),
                  PlayerButton(
                    loading: state.isLoading,
                    onPressed:
                        ref.read(playerControllerProvider.notifier).fastForward,
                    icon: const Icon(Icons.forward_30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
