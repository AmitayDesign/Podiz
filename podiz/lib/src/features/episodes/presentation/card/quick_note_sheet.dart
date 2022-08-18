import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_text_field.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommentTextField(
              autofocus: true,
              onSend: (comment) async {
                final time = ref.read(playerTimeStreamProvider).valueOrNull!;
                ref.read(discussionRepositoryProvider).addComment(
                      comment,
                      episodeId: episode.id,
                      time: time.position,
                      user: ref.read(currentUserProvider),
                    );
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: UsersListening(
                episode: episode,
                //TODO locales text
                textBuilder: (count, _) => "$count listening right now",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//TODO move to another file
class UsersListening extends ConsumerWidget {
  final Episode episode;
  final String Function(
    int totalUsersWatching,
    int otherUsersWatching,
  ) textBuilder;

  const UsersListening({
    Key? key,
    required this.episode,
    required this.textBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveEpisode =
        ref.watch(episodeStreamProvider(episode.id)).valueOrNull ?? episode;
    final user = ref.watch(currentUserProvider);
    final totalUsersWatching = liveEpisode.userIdsWatching;
    final otherUsersWatching = totalUsersWatching..remove(user);
    //TODO add faces
    return Text(
      textBuilder(totalUsersWatching.length, otherUsersWatching.length),
      style: context.textTheme.bodySmall,
    );
  }
}
