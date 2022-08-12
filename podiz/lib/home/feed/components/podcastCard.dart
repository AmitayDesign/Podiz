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
  const PodcastCard(this.podcast, {Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium;
    final subitleStyle = context.textTheme.bodyMedium;

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
              .add(const EdgeInsets.only(bottom: 12)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: InsightsRow(podcast: podcast),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PodcastAvatar(imageUrl: podcast.image_url, size: 64),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.name,
                            style: titleStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  podcast.show_name,
                                  style: subitleStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ' $dot ${timeFormatter(podcast.duration_ms)}',
                                style: subitleStyle,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
