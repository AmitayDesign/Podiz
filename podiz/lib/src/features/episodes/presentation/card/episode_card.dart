import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_content.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/routing/app_router.dart';

class EpisodeCard extends ConsumerWidget {
  final Episode episode;
  final Widget? bottom;
  const EpisodeCard(this.episode, {Key? key, this.bottom}) : super(key: key);

  void openEpisode(BuildContext context, Reader read, Episode episode) {
    // just call play() if the episode is NOT playing
    read(playerRepositoryProvider).fetchPlayingEpisode().then(
      (playingEpisode) {
        if (playingEpisode?.id != episode.id) {
          read(playerRepositoryProvider).play(episode.id);
        }
      },
    );
    context.goNamed(
      AppRoute.discussion.name,
      params: {'episodeId': episode.id},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: InkWell(
        onTap: () => openEpisode(context, ref.read, episode),
        child: EpisodeContent(episode, bottom: bottom),
      ),
    );
  }
}
