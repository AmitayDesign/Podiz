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
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/palette.dart';

class QuickNoteSheet extends ConsumerWidget {
  final Episode episode;
  const QuickNoteSheet({Key? key, required this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                final time = ref.read(playerTimeStreamProvider).valueOrNull!;
                final comment = Comment(
                  text: text,
                  episodeId: episode.id,
                  userId: ref.read(currentUserProvider).id,
                  timestamp: time.position,
                );
                ref.read(discussionRepositoryProvider).addComment(comment);
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: UsersListeningText(
                (others) => '${others + 1} listening right now'.hardcoded,
                episode: episode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
