import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/users_listening_text.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_text_field.dart';
import 'package:podiz/src/features/discussion/presentation/discussion_controller.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/error_comment_sheet.dart';
import 'package:podiz/src/features/discussion/presentation/sheet/skeleton_comment_sheet.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/card/quick_note_sheet.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/features/showcase/presentation/package_files/showcase_widget.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_controller.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_step.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

import 'target_comment.dart';

final commentSheetTargetProvider = StateProvider<Comment?>((ref) => null);

class CommentSheet extends ConsumerWidget {
  static final height = 116.0 + (Platform.isIOS ? 16 : 0); //! hardcoded

  final Episode? episode;
  const CommentSheet({Key? key, this.episode}) : super(key: key);

  Comment sendComment(
    Reader read,
    String episodeId,
    Comment? target,
    String text,
  ) {
    final comment = Comment(
      text: text,
      episodeId: episodeId,
      userId: read(currentUserProvider).id,
      timestamp: read(playerSliderControllerProvider).position,
      parentIds: target == null ? null : [...target.parentIds, target.id],
      parentUserId: target?.userId,
    );
    read(discussionRepositoryProvider).addComment(comment);
    read(commentSheetTargetProvider.notifier).state = null;
    return comment;
  }

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
        loading: () => const SkeletonCommentSheet(),
        error: (e, _) => const ErrorCommentSheet(),
        data: (episode) {
          if (episode == null) {
            if (this.episode == null) {
              return const SizedBox.shrink();
            } else {
              return QuickNoteSheet(episode: this.episode!);
            }
          }
          return showcase(
            context,
            ref.read,
            episodeId: episode.id,
            child: Material(
              color: Palette.grey900,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(kBorderRadius),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8).add(
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
                              if (this.episode != null) Navigator.pop(context);
                              ref
                                  .read(commentSheetTargetProvider.notifier)
                                  .state = null;
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

                    //* Comment text field
                    CommentTextField(
                      autofocus: isReply || this.episode != null,
                      hint:
                          isReply ? 'Add a reply...' : 'Share your insight...',
                      onSend: (text) {
                        final comment =
                            sendComment(ref.read, episode.id, target, text);
                        final isShowcasing = ref.read(showcaseRunningProvider);
                        if (isShowcasing) {
                          addCommentToShowcase(ref.read, episode.id, comment);
                          addExampleToShowcase(ref.read, episode.id);
                          ShowCaseWidget.of(context).next();
                        }
                        if (this.episode != null) Navigator.pop(context);
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
                                          .read(
                                              playerControllerProvider.notifier)
                                          .pause(),
                                  icon: Icons.pause_rounded,
                                )
                              : PlayerTimeChip(
                                  loading: state == PlayerControls.play,
                                  onTap: () => state != null
                                      ? null
                                      : ref
                                          .read(
                                              playerControllerProvider.notifier)
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
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void addCommentToShowcase(Reader read, String episodeId, Comment comment) {
    final discussionController =
        read(filteredCommentsProvider(episodeId).notifier);
    discussionController.addComment(comment);
  }

  void addExampleToShowcase(Reader read, String episodeId) {
    final example = Comment(
      id: 'showcase',
      text: 'Looking forward to this episode!',
      episodeId: episodeId,
      userId: 'hmrs28xr9apw0mlac2dfjwm2v', //! ami id hardcoded
      timestamp: read(playerSliderControllerProvider).position,
    );
    addCommentToShowcase(read, episodeId, example);
  }

  Widget showcase(
    BuildContext context,
    Reader read, {
    required String episodeId,
    required Widget child,
  }) {
    return ShowcaseStep(
      step: 2,
      skipOnTop: true,
      onTap: () {
        final text = read(commentControllerProvider).text;
        if (text.isEmpty) {
          final node = read(commentNodeProvider)..unfocus();
          Future.microtask(node.requestFocus);
        } else {
          final comment = sendComment(read, episodeId, null, text);
          addCommentToShowcase(read, episodeId, comment);
          addExampleToShowcase(read, episodeId);
          read(commentControllerProvider).clear();
          read(commentNodeProvider).unfocus();
          ShowCaseWidget.of(context).next();
        }
      },
      onNext: () {
        addExampleToShowcase(read, episodeId);
        read(commentControllerProvider).clear();
        read(commentNodeProvider).unfocus();
      },
      title: 'Comment what you think',
      description: '"I love that example, it made think about..."',
      child: child,
    );
  }
}
