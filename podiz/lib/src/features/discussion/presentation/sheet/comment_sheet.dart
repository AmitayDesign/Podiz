import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/users_listening_text.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_text_field.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

import 'target_comment.dart';

final commentSheetTargetProvider = StateProvider<Comment?>((ref) => null);

class CommentSheet extends ConsumerWidget {
  static const height = 116.0; //! hardcoded
  const CommentSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeValue = ref.watch(playerStateChangesProvider);
    final state = ref.watch(playerControllerProvider);
    final target = ref.watch(commentSheetTargetProvider);
    final isReply = target != null;
    return WillPopScope(
      onWillPop: () async {
        ref.read(commentSheetTargetProvider.notifier).state = null;
        return true;
      },
      child: episodeValue.when(
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
                  //* Parent comment (if is a reply)
                  if (isReply) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Replying to...'.hardcoded,
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(commentSheetTargetProvider.notifier)
                              .state = null,
                          child: Text(
                            'Cancel'.hardcoded,
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    TargetComment(target),
                    const SizedBox(height: 16),
                  ],

                  //* Comment text field
                  CommentTextField(
                    autofocus: isReply,
                    hint: isReply ? 'Add a reply...' : 'Share your insight...',
                    onSend: (text) {
                      final time = ref.read(playerSliderControllerProvider);
                      final comment = Comment(
                        text: text,
                        episodeId: episode.id,
                        userId: ref.read(currentUserProvider).id,
                        timestamp: time.position,
                        parentIds: target?.parentIds?..add(target!.id),
                      );
                      ref
                          .read(discussionRepositoryProvider)
                          .addComment(comment);

                      ref.read(commentSheetTargetProvider.notifier).state =
                          null;
                    },
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        //* Listening with you
                        Expanded(
                          child: UsersListeningText(
                            (others) => '$others listening with you'.hardcoded,
                            episode: episode,
                          ),
                        ),

                        //* Player controls
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
        },
      ),
    );
  }
}
