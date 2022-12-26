import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/users_listening_text.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_text_field.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/player/presentation/player_button.dart';
import 'package:podiz/src/features/player/presentation/player_controller.dart';
import 'package:podiz/src/features/player/presentation/player_slider_controller.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/palette.dart';

class QuickNoteSheet extends ConsumerWidget {
  final Episode episode;
  const QuickNoteSheet({Key? key, required this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    return Material(
      color: Palette.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kBorderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8).add(
          Platform.isIOS ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommentTextField(
              autofocus: true,
              onSend: (text) {
                final comment = Comment(
                  text: text,
                  episodeId: episode.id,
                  userId: ref.read(currentUserProvider).id,
                  timestamp: ref.read(playerSliderControllerProvider).position,
                );
                ref.read(discussionRepositoryProvider).addComment(comment);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  //* Listening right now
                  Expanded(
                    child: UsersListeningText(
                      (others) => '${others + 1} listening right now'.hardcoded,
                      episode: episode,
                    ),
                  ),

                  //* Player controls
                  PlayerButton(
                    loading: state.isLoading,
                    onPressed:
                        ref.read(playerControllerProvider.notifier).rewind,
                    icon: const Icon(Icons.replay_30_rounded),
                  ),
                  PlayerTimeChip(
                    loading: state.isLoading,
                    onTap: () => ref
                        .read(playerControllerProvider.notifier)
                        .play(episode.id),
                    icon: Icons.play_arrow_rounded,
                  ),
                  PlayerButton(
                    loading: state.isLoading,
                    onPressed:
                        ref.read(playerControllerProvider.notifier).fastForward,
                    icon: const Icon(Icons.forward_30_rounded),
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
