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
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/providers.dart';

class PodcastTile extends ConsumerWidget {
  final SearchResult result;
  const PodcastTile(this.result, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlaying = ref.watch(playerStreamProvider).valueOrNull?.getState ==
        PlayerState.play;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (result.show_name == null) {
            context.goNamed(
              AppRoute.show.name,
              params: {'showId': result.show_uri!},
            );
          } else {
            ref.read(playerManagerProvider).playEpisode(result.toPodcast(), 0);
            context.pushNamed(
              AppRoute.discussion.name,
              params: {'showId': result.show_uri!},
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
                PodcastAvatar(imageUrl: result.image_url, size: 68),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          result.name,
                          style: context.textTheme.titleLarge!.copyWith(
                            color: isPlaying
                                ? context.colorScheme.primary
                                : Colors.grey.shade50,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      result.show_name != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => context.goNamed(
                                      AppRoute.show.name,
                                      params: {'showId': result.show_uri!},
                                    ),
                                    child: Text(
                                      result.show_name!,
                                      style:
                                          context.textTheme.bodyLarge!.copyWith(
                                        color: Palette.grey600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                                  timeFormatter(result.duration_ms!),
                                  style: context.textTheme.bodyLarge!.copyWith(
                                    color: Palette.grey600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
