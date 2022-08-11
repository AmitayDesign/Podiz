import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/widgets/insightsRow.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';

class PodcastListTileQuickNote extends StatelessWidget {
  final Podcast podcast;
  final Widget quickNote;

  const PodcastListTileQuickNote(
    this.podcast, {
    Key? key,
    required this.quickNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: theme.colorScheme.surface,
        ),
        child: Column(children: [
          InsightsRow.quickNote(podcast),
          const SizedBox(height: 8),
          Row(
            children: [
              PodcastAvatar(imageUrl: podcast.image_url, size: 52),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        podcast.name,
                        style: context.textTheme.titleMedium!.copyWith(
                          color: Palette.grey600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        podcast.show_name,
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: Palette.grey800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          quickNote,
        ]),
      ),
    );
  }
}
