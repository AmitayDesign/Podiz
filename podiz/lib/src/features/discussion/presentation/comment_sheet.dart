import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/episodes/presentation/card/quick_note_sheet.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/palette.dart';

import 'comment/comment_text_field.dart';

final commentSheetVisibilityProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);

class CommentSheet extends ConsumerWidget {
  static const height = 116.0; //! hardcoded
  const CommentSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeValue = ref.watch(playerStateChangesProvider);
    final state = ref.watch(playerControllerProvider);
    return episodeValue.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => const SizedBox.shrink(),
        data: (episode) {
          if (episode == null) return const SizedBox.shrink();
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
                  CommentTextField(
                    onSend: (comment) {
                      final time =
                          ref.read(playerTimeStreamProvider).valueOrNull!;
                      ref.read(discussionRepositoryProvider).addComment(
                            comment,
                            episodeId: episode.id,
                            time: time.position,
                            user: ref.read(currentUserProvider),
                          );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                    child: Row(
                      children: [
                        UsersListening(
                          episode: episode,
                          //TODO locales text
                          textBuilder: (_, count) =>
                              "$count listening with you",
                        ),
                        Text(
                          '${episode.userIdsWatching.length - 1} listening with you'
                              .hardcoded,
                          style: context.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        PlayerButton(
                          loading: state.isLoading,
                          onPressed: ref
                              .read(playerControllerProvider.notifier)
                              .rewind,
                          icon: const Icon(Icons.replay_30),
                        ),
                        episode.isPlaying
                            ? PlayerTimeChip(
                                loading: state.isLoading,
                                onTap: ref
                                    .read(playerControllerProvider.notifier)
                                    .pause,
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
                          onPressed: ref
                              .read(playerControllerProvider.notifier)
                              .fastForward,
                          icon: const Icon(Icons.forward_30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
