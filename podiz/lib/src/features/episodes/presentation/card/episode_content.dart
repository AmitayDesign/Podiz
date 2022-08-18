import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/widgets/dot.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/utils/zwsp_string.dart';

import 'insights_info.dart';

class EpisodeContent extends StatelessWidget {
  final Episode episode;
  final Widget? bottom;

  /// The color to give to the stacked avatars border
  final Color? color;

  const EpisodeContent(
    this.episode, {
    Key? key,
    this.bottom,
    this.color,
  }) : super(key: key);

  String format(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final time = duration.toString().split('.').first.split(':');
    final hours = time.first;
    final minutes = time.last;
    if (hours == '0') return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium;
    final subtitleStyle = context.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16)
          .add(const EdgeInsets.only(top: 8, bottom: 12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: InsightsInfo(episode: episode, borderColor: color),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PodcastAvatar(
                podcastId: episode.showId,
                imageUrl: episode.imageUrl,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.name,
                        style: titleStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => context.goNamed(
                                AppRoute.podcast.name,
                                params: {'showId': episode.showId},
                              ),
                              child: Text(
                                episode.showName.useCorrectEllipsis(),
                                style: subtitleStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Text(
                            ' $dot ${timeFormatter(episode.duration)}',
                            style: subtitleStyle,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 12),
            bottom!,
          ],
        ],
      ),
    );
  }
}
