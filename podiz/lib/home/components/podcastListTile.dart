import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/insightsRow.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/screens/discussionPage.dart';

class PodcastListTile extends ConsumerWidget {
  Podcast podcast;
  PodcastListTile(this.podcast, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          ref.read(playerManagerProvider).playEpisode(podcast, 0);
          Navigator.pushNamed(context, DiscussionPage.route);
        },
        child: Container(
          height: 148,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadius),
            color: theme.colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InsightsRow(podcast),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PodcastAvatar(imageUrl: podcast.image_url, size: 68),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: kScreenWidth - (16 + 16 + 68 + 8 + 16 + 16),
                      height: 68,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              podcast.name,
                              style: podcastTitle(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          LimitedBox(
                            maxWidth:
                                kScreenWidth - (16 + 16 + 68 + 8 + 16 + 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: LimitedBox(
                                      maxWidth: kScreenWidth -
                                          (16 +
                                              16 +
                                              68 +
                                              8 +
                                              12 +
                                              4 +
                                              12 +
                                              16 +
                                              58 +
                                              16),
                                      child: Text(podcast.show_name,
                                          style: podcastArtist()),
                                    )),
                                const SizedBox(width: 12),
                                ClipOval(
                                    child: Container(
                                  width: 4,
                                  height: 4,
                                  color: const Color(0xFFD9D9D9),
                                )),
                                const SizedBox(width: 12),
                                Text(timeFormatter(podcast.duration_ms),
                                    style: podcastArtist()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
