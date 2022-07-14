import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/insightsRow.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/feed/components/quickNote.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/objects/Podcast.dart';

class PodcastListTileQuickNote extends StatelessWidget {
  Podcast podcast;

  PodcastListTileQuickNote(this.podcast, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, top: 12),
      child: Container(
        height: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: theme.colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(children: [
            InsightsRow.quickNote(podcast),
            const SizedBox(height: 8),
            Row(
              children: [
                PodcastAvatar(imageUrl: podcast.image_url, size: 52),
                const SizedBox(width: 8),
                Container(
                  width: 250, //TODO see this
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          podcast.name,
                          style: podcastTitleQuickNote(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(podcast.show_name,
                              style: podcastArtistQuickNote())),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            QuickNote(podcast),
          ]),
        ),
      ),
    );
  }
}
