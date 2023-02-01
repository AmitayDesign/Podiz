import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/users_listening_text.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/domain/mutable_comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_text_field.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

import 'error_comment_sheet.dart';
import 'skeleton_comment_sheet.dart';
import 'target_comment.dart';

final commentSheetTargetProvider = StateProvider<Comment?>((ref) => null);
final commentSheetEditProvider = StateProvider<Comment?>((ref) => null);

class CommentSheet extends ConsumerWidget {
  static final height = 116.0 + (Platform.isIOS ? 16 : 0); //! hardcoded

  final Episode episode;
  final bool pinned;
  const CommentSheet(this.episode, {Key? key, this.pinned = false})
      : super(key: key);

  void editComment(
    Reader read,
    String text,
  ) {
    final comment = read(commentSheetEditProvider)!.setText(text);
    read(discussionRepositoryProvider).updateComment(comment);
    read(commentSheetEditProvider.notifier).state = null;
    read(commentControllerProvider).clear();
  }

  void sendComment(
    Reader read,
    String episodeId,
    Comment? target,
    String text,
  ) {
    final comment = Comment(
      text: text,
      episodeId: episodeId,
      userId: read(currentUserProvider).id,
      timestamp: target == null
          ? read(playerSliderControllerProvider).position
          : target.timestamp,
      parentIds: target == null ? null : [...target.parentIds, target.id],
      parentUserId: target?.userId,
    );
    read(discussionRepositoryProvider).addComment(comment);
    read(commentSheetTargetProvider.notifier).state = null;
  }

  Comment sendReply(
    Reader read,
    String episodeId,
    Comment? target,
    Duration timestamp,
    String text,
  ) {
    final comment = Comment(
      text: text,
      episodeId: episodeId,
      userId: read(currentUserProvider).id,
      timestamp: timestamp,
      parentIds: target == null ? null : [...target.parentIds, target.id],
      parentUserId: target?.userId,
    );
    read(discussionRepositoryProvider).addComment(comment);
    read(commentSheetTargetProvider.notifier).state = null;
    return comment;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final target = ref.watch(commentSheetTargetProvider);
    final isReply = target != null;
    final edit = ref.watch(commentSheetEditProvider);
    final isEditing = edit != null;
    return WillPopScope(
      onWillPop: () async {
        ref.read(commentSheetTargetProvider.notifier).state = null;
        if (isEditing) {
          ref.read(commentSheetEditProvider.notifier).state = null;
          ref.read(commentControllerProvider).clear();
        }
        return true;
      },
      child: Material(
        color: Palette.grey900,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8).add(
            Platform.isIOS
                ? const EdgeInsets.only(bottom: 16)
                : EdgeInsets.zero,
          ),
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
                      onPressed: () {
                        if (!pinned) Navigator.pop(context);
                        ref.read(commentSheetTargetProvider.notifier).state =
                            null;
                      },
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

              //* Current comment (if it is an edit)
              if (isEditing) ...[
                Row(
                  children: [
                    const Icon(Icons.edit, size: kSmallIconSize),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Editing...'.hardcoded,
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (!pinned) Navigator.pop(context);
                        ref.read(commentSheetEditProvider.notifier).state =
                            null;
                      },
                      child: Text(
                        'Cancel'.hardcoded,
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              //* Comment text field
              CommentTextField(
                comment: edit,
                autofocus: isReply || isEditing || !pinned,
                hint: isReply ? 'Add a reply...' : 'Share your insight...',
                onSend: (text) {
                  isEditing
                      ? editComment(ref.read, text)
                      : sendComment(ref.read, episode.id, target, text);
                  if (!pinned) Navigator.pop(context);
                },
              ),
              Consumer(
                builder: (context, ref, _) {
                  final episodeValue = ref.watch(playerStateChangesProvider);
                  return episodeValue.when(
                      loading: () => const SkeletonCommentSheet(),
                      error: (e, _) => const ErrorCommentSheet(),
                      data: (episode) {
                        if (episode == null || episode.id != this.episode.id) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.all(4)
                              .add(const EdgeInsets.only(top: 4)),
                          child: Row(
                            children: [
                              //* Listening with you
                              Expanded(
                                child: UsersListeningText(
                                  (others) =>
                                      '$others listening with you'.hardcoded,
                                  episode: episode,
                                ),
                              ),

                              //* Player controls
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
                                  ? PlayerTimeChip(
                                      loading: state == PlayerControls.pause,
                                      onTap: () => state != null
                                          ? null
                                          : ref
                                              .read(playerControllerProvider
                                                  .notifier)
                                              .pause(),
                                      icon: Icons.pause_rounded,
                                    )
                                  : PlayerTimeChip(
                                      loading: state == PlayerControls.play,
                                      onTap: () => state != null
                                          ? null
                                          : ref
                                              .read(playerControllerProvider
                                                  .notifier)
                                              .play(episode.id),
                                      icon: Icons.play_arrow_rounded,
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
                        );
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
