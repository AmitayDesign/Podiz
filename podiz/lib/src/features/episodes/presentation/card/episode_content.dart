import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/src/common_widgets/dot.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/utils/string_zwsp.dart';

import 'insights_info.dart';

class EpisodeContent extends StatelessWidget {
  final Episode episode;
  final bool insights;
  final Widget? bottom;

  /// The color to give to the stacked avatars border
  final Color? color;
  final double avatarSize;
  final int titleMaxLines;

  const EpisodeContent(
    this.episode, {
    Key? key,
    this.insights = true,
    this.bottom,
    this.color,
    this.avatarSize = 64,
    this.titleMaxLines = 2,
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
          if (insights)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 16),
              child: InsightsInfo(episode: episode, borderColor: color),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PodcastAvatar(
                podcastId: episode.showId,
                imageUrl: episode.imageUrl,
                size: avatarSize,
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
                        maxLines: titleMaxLines,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => context.goNamed(
                                AppRoute.podcast.name,
                                params: {'podcastId': episode.showId},
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
