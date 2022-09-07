import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/empty_screen.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/sliver_firestore_query_builder.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/podcast/podcast_follow_fab.dart';
import 'package:podiz/src/features/episodes/presentation/podcast/podcast_sliver_bar.dart';
import 'package:podiz/src/features/player/presentation/player.dart';

class PodcastScreen extends ConsumerStatefulWidget {
  final String podcastId;
  const PodcastScreen(this.podcastId, {Key? key}) : super(key: key);

  @override
  ConsumerState<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends ConsumerState<PodcastScreen> {
  final scrollController = ScrollController();

  double get statusBarHeight => MediaQuery.of(context).padding.top;
  double get minHeight => statusBarHeight + GradientBar.height * 1.5;
  double get maxHeight => statusBarHeight + 320;

  void snapHeader() {
    final distance = maxHeight - minHeight;
    final offset = scrollController.offset;
    if (offset > 0 && offset < distance) {
      final snapOffset = offset / distance > 0.5 ? distance : 0.0;
      Future.microtask(
        () => scrollController.animateTo(
          snapOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final episodeRepository = ref.watch(episodeRepositoryProvider);
    final podcastValue = ref.watch(podcastStreamProvider(widget.podcastId));

    //TODO podcast empty screen
    return podcastValue.when(
      loading: () => EmptyScreen.loading(),
      error: (e, _) => EmptyScreen.text(
        'There was an error opening this podcast.',
      ),
      data: (podcast) => Scaffold(
        extendBody: true,
        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(podcastRepositoryProvider).refetchPodcast(podcast.id),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              snapHeader();
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              slivers: [
                //* Sliver app bar
                PodcastSliverHeader(
                  podcast: podcast,
                  minHeight: minHeight,
                  maxHeight: maxHeight,
                ),

                //* List of episodes
                SliverFirestoreQueryBuilder<Episode>(
                  query:
                      episodeRepository.showEpisodesFirestoreQuery(podcast.id),
                  builder: (context, episode) =>
                      EpisodeCard(episode, podcast: podcast),
                ),

                // so it doesnt end behind the bottom bar
                const SliverToBoxAdapter(
                    child: SizedBox(height: Player.height)),
              ],
            ),
          ),
        ),
        floatingActionButton: PodcastFollowFab(
          podcastId: widget.podcastId,
          imageUrl: podcast.imageUrl,
        ),
        bottomNavigationBar: const Player(),
      ),
    );
  }
}
