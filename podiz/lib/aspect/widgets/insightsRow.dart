import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/objects/Podcast.dart';

class InsightsRow extends StatelessWidget {
  Podcast podcast;
  InsightsRow(this.podcast, {Key? key}) : super(key: key);
  InsightsRow.quickNote(this.podcast, {Key? key})
      : style = podcastArtistQuickNote(),
        size = 23,
        super(key: key);

  TextStyle style = podcastInsights();
  double size = 32;
  @override
  Widget build(BuildContext context) {
    if (podcast.comments == 0) {
      return SizedBox(
        height: size,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            Locales.string(context, "noinsigths"),
            style: style,
          ),
        ),
      );
    }
    return Row(
      children: [
        StackedImages(podcast, size: size),
        const SizedBox(width: 8),
        Text(
          "${podcast.comments} Insights",
          style: podcastInsights(),
        ),
      ],
    );
  }
}
