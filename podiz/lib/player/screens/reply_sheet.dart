import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/discussion/presentation/comment_sheet_content.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/theme/palette.dart';

class ReplySheet extends ConsumerWidget {
  final Comment comment;
  const ReplySheet({Key? key, required this.comment}) : super(key: key);

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: CommentSheetContent(
          key: UniqueKey(),
          onSend: (text) {
            final episode = ref.read(playerStateChangesProvider).valueOrNull!;
            final playerTime = ref.read(playerTimeStreamProvider).valueOrNull!;
            ref.read(discussionRepositoryProvider).addComment(
                  text,
                  episodeId: episode.id,
                  time: playerTime.position,
                  user: ref.read(currentUserProvider),
                  parent: comment,
                );
          },
        ),
      ),
    );
  }
}
