import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/widgets/dot.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';

import 'insights_info.dart';

class EpisodeContent extends StatelessWidget {
  final Episode episode;
  final VoidCallback? onTap;
  final Widget? bottom;

  const EpisodeContent(
    this.episode, {
    Key? key,
    this.onTap,
    this.bottom,
  }) : super(key: key);

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
            child: InsightsInfo(episode: episode),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PodcastAvatar(imageUrl: episode.imageUrl),
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
                              onTap: onTap,
                              child: Text(
                                episode.showName,
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
