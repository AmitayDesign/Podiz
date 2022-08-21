import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_content.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/routing/app_router.dart';

class EpisodeCard extends ConsumerWidget {
  final Episode episode;
  final Podcast podcast;
  final bool insights;
  final Widget? bottom;

  const EpisodeCard(
    this.episode, {
    required this.podcast,
    Key? key,
    this.insights = true,
    this.bottom,
  }) : super(key: key);

  void openEpisode(BuildContext context, Reader read) async {
    final playerRepository = read(playerRepositoryProvider);
    context.pushNamed(
      AppRoute.discussion.name,
      params: {'episodeId': episode.id},
    );
    // just call play() if the episode is NOT playing
    final playingEpisode = await playerRepository.fetchPlayingEpisode();
    if (playingEpisode?.id != episode.id) playerRepository.play(episode.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: InkWell(
        onTap: () => openEpisode(context, ref.read),
        child: EpisodeContent(
          episode,
          podcast: podcast,
          insights: insights,
          bottom: bottom,
        ),
      ),
    );
  }
}
