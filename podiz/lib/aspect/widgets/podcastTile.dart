import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/player/PlayerManager.dart';

class PodcastTile extends ConsumerStatefulWidget {
  final SearchResult result;
  final bool isPlaying;

  const PodcastTile(this.result, {required this.isPlaying, Key? key})
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
            context.goNamed(
              AppRoute.show.name,
              params: {'showId': widget.result.show_uri!},
            );
          } else {
            ref
                .read(playerManagerProvider)
                .playEpisode(widget.result.searchResultToPodcast(), 0);
            context.pushNamed(
              AppRoute.discussion.name,
              params: {'showId': widget.result.show_uri!},
            );
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.result.name,
                          style: context.textTheme.titleLarge!.copyWith(
                            color: widget.isPlaying
                                ? context.colorScheme.primary
                                : Colors.grey.shade50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      widget.result.show_name != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.result.show_name!,
                                    style:
                                        context.textTheme.bodyLarge!.copyWith(
                                      color: Palette.grey600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ClipOval(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    color: const Color(0xFFD9D9D9),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  timeFormatter(widget.result.duration_ms!),
                                  style: context.textTheme.bodyLarge!.copyWith(
                                    color: Palette.grey600,
                                  ),
                                ), //TODO formatter here
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
