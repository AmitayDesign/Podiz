import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/home/components/followShowButton.dart';
import 'package:podiz/home/search/components/podcastShowTile.dart';
import 'package:podiz/loading.dart/episodeLoading.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/player/mini_player.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/splash_screen.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';

class ShowPage extends ConsumerWidget {
  final String showId;
  const ShowPage(this.showId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showValue = ref.watch(showFutureProvider(showId));
    final player = ref.watch(playerStateChangesProvider).valueOrNull;
    final isPlaying = player?.isPlaying ?? false;
    return showValue.when(
      error: (e, _) {
        return const SplashScreen.error();
      },
      loading: () => const SplashScreen(),
      data: (show) => Scaffold(
        appBar: BackAppBar(),
        body: Column(
          children: [
            //TODO SliverAppBar
            PodcastAvatar(imageUrl: show.image_url, size: 124),
            const SizedBox(height: 16),
            Text(
              show.name,
              style: context.textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "${show.followers.length} Following",
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Consumer(
                        builder: (context, ref, _) {
                          final episodeId = show.podcasts[i];
                          final episodeValue =
                              ref.watch(episodeFutureProvider(episodeId));
                          return episodeValue.when(
                              loading: () => const EpisodeLoading(),
                              error: (e, _) => Center(
                                    child: Text(
                                      '$e occurred',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                              data: (episode) {
                                final searchResult =
                                    SearchResult.fromEpisode(episode);
                                return PodcastShowTile(
                                  searchResult,
                                  isPlaying:
                                      isPlaying && player?.id == episode.id,
                                );
                              });
                        },
                      ),
                      childCount: show.podcasts.length,
                    ),
                    // p.getState != PlayerState.close
                    //     ? const Positioned(
                    //         bottom: 0.0,
                    //         left: 0.0,
                    //         right: 0.0,
                    //         child: MiniPlayer(),
                    //       )
                    //     : Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FollowShowButton(
          show.uid!,
          imageUrl: show.image_url,
          isPlaying: isPlaying,
        ),
        bottomNavigationBar: isPlaying ? const MiniPlayer() : null,
      ),
    );
  }
}
