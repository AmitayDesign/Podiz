import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';

class UsersListeningText extends ConsumerWidget {
  final String Function(
    int totalUsersWatching,
    int otherUsersWatching,
  ) textBuilder;
  final Episode episode;

  const UsersListeningText(
    this.textBuilder, {
    Key? key,
    required this.episode,
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