import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/insightsRow.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/home/search/screens/showPage.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/profile/screens/settingsPage.dart';

class PodcastShowTile extends ConsumerStatefulWidget {
  SearchResult result;
  bool isPlaying;

  PodcastShowTile(this.result, {required this.isPlaying, Key? key})
      : super(key: key);

  @override
  ConsumerState<PodcastShowTile> createState() => _PodcastShowTileState();
}

class _PodcastShowTileState extends ConsumerState<PodcastShowTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => ref
            .read(playerManagerProvider)
            .playEpisode(widget.result.searchResultToPodcast()),
        child: Container(
          height: 188,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadius),
            color: theme.colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              children: [
                InsightsRow(widget.result.searchResultToPodcast()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PodcastAvatar(imageUrl: widget.result.image_url, size: 52),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.result.name,
                              style: widget.isPlaying
                                  ? podcastTitlePlaying()
                                  : podcastTitle(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      dateFormatter(
                                          widget.result.release_date!),
                                      style: podcastArtist())),
                              const SizedBox(width: 12),
                              ClipOval(
                                  child: Container(
                                width: 4,
                                height: 4,
                                color: const Color(0xFFD9D9D9),
                              )),
                              const SizedBox(width: 12),
                              Text(timeFormatter(widget.result.duration_ms!),
                                  style: podcastArtist()), //TODO formatter here
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  widget.result.description!,
                  style: showDescription(),
                  maxLines: 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
