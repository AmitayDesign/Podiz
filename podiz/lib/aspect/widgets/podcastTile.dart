import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/search/screens/showPage.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/screens/discussionPage.dart';
import 'package:podiz/profile/screens/settingsPage.dart';

class PodcastTile extends ConsumerStatefulWidget {
  SearchResult result;
  bool isPlaying;

  PodcastTile(this.result, {required this.isPlaying, Key? key})
      : super(key: key);

  @override
  ConsumerState<PodcastTile> createState() => _PodcastTileState();
}

class _PodcastTileState extends ConsumerState<PodcastTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (widget.result.show_name == null) {
            Navigator.pushNamed(context, ShowPage.route,
                arguments: widget.result.searchResultToPodcaster());
          } else {
            ref
                .read(playerManagerProvider)
                .playEpisode(widget.result.searchResultToPodcast(), 0);
            Navigator.pushNamed(context, DiscussionPage.route);
          }
        },
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadius),
            color: theme.colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                PodcastAvatar(imageUrl: widget.result.image_url, size: 68),
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
                      widget.result.show_name != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: 150, //see this
                                      child: Text(widget.result.show_name!,
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
                                Text(timeFormatter(widget.result.duration_ms!),
                                    style:
                                        podcastArtist()), //TODO formatter here
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}