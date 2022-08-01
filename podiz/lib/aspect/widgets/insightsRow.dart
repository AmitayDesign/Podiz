import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/Podcast.dart';

class InsightsRow extends ConsumerWidget {
  Podcast podcast;
  InsightsRow(this.podcast, {Key? key}) : super(key: key);
  InsightsRow.quickNote(this.podcast, {Key? key})
      : style = podcastArtistQuickNote(),
        size = 23,
        super(key: key);

  TextStyle style = podcastInsights();
  double size = 32;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (podcast.comments == 0) {
      return SizedBox(
        height: size,
        width: kScreenWidth - (16 + 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleProfile(
                user: ref.read(authManagerProvider).userBloc!, size: 16),
            SizedBox(width: 8),
            LimitedBox(
              maxWidth: kScreenWidth - (16 + 16 + 32 + 8 + 12 + 12),
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