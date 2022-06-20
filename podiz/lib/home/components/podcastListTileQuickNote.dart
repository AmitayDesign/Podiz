import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/QuickNote.dart';
import 'package:podiz/home/components/stackedImages.dart';

class PodcastListTileQuickNote extends StatelessWidget {
  PodcastListTileQuickNote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        child: buildItem(context),
      ),
    );
  }

  Widget buildItem(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        height: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: theme.colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(children: [
            Row(
              children: [
                StackedImages(23),
                const SizedBox(width: 8),
                Text(
                  "120 Insights",
                  style: podcastInsightsQuickNote(),
                ),
                const Spacer(),
                Text(
                  "11:17 Today",
                  style: podcastInsightsQuickNote(),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    color: theme.primaryColor,
                  ),
                  width: 52,
                  height: 52,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 250, //TODO see this
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Here's the Renegades|Stop...",
                          style: podcastTitleQuickNote(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text("The Daily Stoic",
                              style: podcastArtistQuickNote())),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            const QuickNote(),
          ]),
        ),
      ),
    );
  }
}
