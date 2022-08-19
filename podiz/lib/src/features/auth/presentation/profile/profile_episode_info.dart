import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';

class ProfileEpisodeInfo extends ConsumerWidget {
  final String episodeId;

  const ProfileEpisodeInfo(this.episodeId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = context.textTheme.titleMedium;
    final subtitleStyle = context.textTheme.bodyMedium;
    final episodeValue = ref.watch(episodeFutureProvider(episodeId));

    return episodeValue.when(
      loading: () => const SizedBox.shrink(), //!
      error: (e, _) => const SizedBox.shrink(),
      data: (episode) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .add(const EdgeInsets.only(top: 8, bottom: 12)),
          child: Row(
            children: [
              PodcastAvatar(
                podcastId: episode.showId,
                imageUrl: episode.imageUrl,
                size: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.name,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed(
                        AppRoute.podcast.name,
                        params: {'podcastId': episode.showId},
                      ),
                      child: Text(
                        episode.showName,
                        style: subtitleStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
