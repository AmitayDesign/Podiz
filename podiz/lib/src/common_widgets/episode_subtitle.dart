import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

class EpisodeSubtitle extends StatelessWidget {
  final Episode episode;
  final Podcast podcast;

  const EpisodeSubtitle(this.episode, this.podcast, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium;
    final subtitleStyle = context.textTheme.bodyMedium;

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoute.discussion.name,
        params: {'episodeId': episode.id},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16)
            .add(const EdgeInsets.only(top: 8, bottom: 12)),
        child: Row(
          children: [
            PodcastAvatar(imageUrl: episode.imageUrl, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.name,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    podcast.name,
                    style: subtitleStyle,
                    overflow: TextOverflow.ellipsis,
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
