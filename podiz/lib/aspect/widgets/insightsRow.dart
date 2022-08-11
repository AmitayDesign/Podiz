import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart';

class InsightsRow extends ConsumerWidget {
  final Podcast podcast;
  final TextStyle style;
  final double size;

  InsightsRow(this.podcast, {Key? key})
      : style = podcastInsights(),
        size = 32,
        super(key: key);

  InsightsRow.quickNote(this.podcast, {Key? key})
      : style = podcastArtistQuickNote(),
        size = 23,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (podcast.comments == 0) {
      return SizedBox(
        height: size,
        width: kScreenWidth - (16 + 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleProfile(user: user, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: AutoSizeText(
                Locales.string(context, "noinsigths"),
                style: style,
                minFontSize: 12,
                maxFontSize: 16,
              ),
            ),
          ],
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
