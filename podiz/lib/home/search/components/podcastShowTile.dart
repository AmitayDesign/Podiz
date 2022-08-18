import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/src/features/episodes/presentation/card/insights_info.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';

class PodcastShowTile extends ConsumerStatefulWidget {
  final SearchResult result;
  final bool isPlaying;

  const PodcastShowTile(this.result, {required this.isPlaying, Key? key})
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
      child: Card(
        clipBehavior: Clip.hardEdge,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: InkWell(
          onTap: () {
            ref
                .read(playerRepositoryProvider)
                .play(widget.result.toEpisode().id);
            context.goNamed(
              AppRoute.discussion.name,
              params: {'podcastId': widget.result.show_uri!},
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              children: [
                InsightsInfo(episode: widget.result.toEpisode()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PodcastAvatar(
                      podcastId: widget.result.show_uri!,
                      imageUrl: widget.result.image_url,
                      size: 52,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.result.name,
                            style: context.textTheme.titleLarge!.copyWith(
                              color: widget.isPlaying
                                  ? context.colorScheme.primary
                                  : Colors.grey.shade50,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                dateFormatter(widget.result.release_date!),
                                style: context.textTheme.bodyLarge!.copyWith(
                                  color: Palette.grey600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 12),
                              ClipOval(
                                  child: Container(
                                width: 4,
                                height: 4,
                                color: const Color(0xFFD9D9D9),
                              )),
                              const SizedBox(width: 12),
                              Text(
                                timeFormatter(widget.result.duration_ms!),
                                style: context.textTheme.bodyLarge!
                                    .copyWith(color: Palette.grey600),
                                overflow: TextOverflow.ellipsis,
                              ), //TODO formatter here
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
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
