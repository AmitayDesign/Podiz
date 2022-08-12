import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/widgets/dot.dart';
import 'package:podiz/aspect/widgets/insightsRow.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';

class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final VoidCallback? onTap;
  final VoidCallback? onShowTap;
  final Widget? bottom;

  const PodcastCard(
    this.podcast, {
    Key? key,
    this.onTap,
    this.onShowTap,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium;
    final subtitleStyle = context.textTheme.bodyMedium;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .add(const EdgeInsets.only(top: 8, bottom: 12)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: InsightsRow(podcast: podcast),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PodcastAvatar(imageUrl: podcast.image_url, size: 64),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.name,
                            style: titleStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: onShowTap,
                                  child: Text(
                                    podcast.show_name,
                                    style: subtitleStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Text(
                                ' $dot ${timeFormatter(podcast.duration_ms)}',
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
        ),
      ),
    );
  }
}
