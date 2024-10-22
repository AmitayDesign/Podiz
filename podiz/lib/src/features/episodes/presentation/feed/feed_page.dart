import 'dart:math';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/card/quick_note_button.dart';
import 'package:podiz/src/features/episodes/presentation/card/skeleton_episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/utils/date_difference.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'feed_bar.dart';
import 'feed_controller.dart';
import 'feed_title.dart';
import 'trending_section.dart';

class FeedPage extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  const FeedPage({Key? key, this.scrollController}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

/// Use the [AutomaticKeepAliveClientMixin] to keep the state.
class _FeedPageState extends ConsumerState<FeedPage>
    with AutomaticKeepAliveClientMixin {
  //
  final myCastsController = PageController();

  late final scrollController = (widget.scrollController ?? ScrollController())
    ..addListener(
      () => ref.read(feedControllerProvider.notifier).handleTitles(),
    );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    ref.read(podcastRepositoryProvider).refetchFavoritePodcasts(user.id);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // call 'super.build' when using 'AutomaticKeepAliveClientMixin'
    super.build(context);

    final user = ref.watch(currentUserProvider);
    final feedController = ref.read(feedControllerProvider.notifier);
    final lastLoaded = ref.watch(lastTrendingDayLoadedProvider);
    final isPlayerAlive =
        ref.watch(playerStateChangesProvider).valueOrNull != null;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(podcastRepositoryProvider).refetchFavoritePodcasts(user.id),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const FeedBar(),
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            // so it doesnt start behind the app bar
            const SliverToBoxAdapter(
              child: SizedBox(height: GradientBar.backgroundHeight + 16),
            ),

            //* Last Listened
            if (user.lastListened != null)
              Consumer(
                builder: (context, ref, _) {
                  final lastListenedValue =
                      ref.watch(episodeFutureProvider(user.lastListened!));
                  return SliverToBoxAdapter(
                    child: lastListenedValue.when(
                      loading: () => const SkeletonEpisodeCard(
                        bottomHeight: QuickNoteButton.height,
                      ),
                      error: (e, _) => null,
                      data: (lastListened) {
                        final podcastValue = ref
                            .watch(podcastFutureProvider(lastListened.showId));
                        return podcastValue.when(
                          loading: () => const SkeletonEpisodeCard(
                            bottomHeight: QuickNoteButton.height,
                          ),
                          error: (e, _) => null,
                          data: (podcast) {
                            return EpisodeCard(
                              lastListened,
                              podcast: podcast,
                              bottom: QuickNoteButton(episode: lastListened),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),

            //* My Casts
            if (user.favPodcasts.isNotEmpty) ...[
              if (user.lastListened != null)
                SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FeedTitle(
                        feedController.myCastsTitle,
                        textKey: feedController.myCastsKey,
                      ),
                      FeedTitleWidget(
                        child: SmoothPageIndicator(
                          controller: myCastsController,
                          count: (user.favPodcasts.length / 2).ceil(),
                          effect: ScrollingDotsEffect(
                            offset: 0,
                            radius: 8,
                            dotWidth: 8,
                            dotHeight: 8,
                            spacing: 8,
                            activeDotScale: 1,
                            dotColor: context.colorScheme.surface,
                            activeDotColor: context.colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SliverToBoxAdapter(
                child: Consumer(builder: (context, ref, _) {
                  final episodeValues = user.favPodcasts
                      .map((podcastId) =>
                          ref.watch(lastShowEpisodeStreamProvider(podcastId)))
                      .toList();
                  final myCastIsLoading =
                      episodeValues.any((value) => value.isLoading);
                  if (!myCastIsLoading) {
                    episodeValues.sort((a, b) {
                      if (a.hasError) return 1;
                      if (b.hasError) return -1;
                      final aReleaseDate = a.value!.releaseDate;
                      final bReleaseDate = b.value!.releaseDate;
                      return bReleaseDate.compareTo(aReleaseDate);
                    });
                  }
                  return ExpandablePageView.builder(
                    controller: myCastsController,
                    itemCount: (episodeValues.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      final first = index * 2;
                      final last = min(first + 2, episodeValues.length);
                      final values = episodeValues.sublist(first, last);

                      // if not sorted yet, show loading
                      if (myCastIsLoading) {
                        return Column(
                          children: List.filled(
                            values.length,
                            const SkeletonEpisodeCard(),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          for (final episodeValue in values)
                            Consumer(builder: (context, ref, _) {
                              return episodeValue.when(
                                  loading: () => const SkeletonEpisodeCard(),
                                  error: (e, _) => const SizedBox.shrink(),
                                  data: (episode) {
                                    if (episode == null) {
                                      return const SizedBox.shrink();
                                    }
                                    final podcastValue = ref.watch(
                                        podcastFutureProvider(episode.showId));
                                    return podcastValue.when(
                                        loading: () =>
                                            const SkeletonEpisodeCard(),
                                        error: (e, _) =>
                                            const SizedBox.shrink(),
                                        data: (podcast) {
                                          final card = EpisodeCard(
                                            episode,
                                            podcast: podcast,
                                          );
                                          return card;
                                        });
                                  });
                            }),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],

            //* Trending
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, days) {
                  if (lastLoaded < days - 1) return null;
                  return Consumer(
                    builder: (context, ref, _) {
                      final episodesValue =
                          ref.watch(trendingEpisodesProvider(days));
                      return episodesValue.when(
                        loading: () => const SizedBox.shrink(),
                        error: (e, _) => const SizedBox.shrink(),
                        data: (episodes) {
                          if (lastLoaded == days - 1) {
                            Future.microtask(
                              () => ref
                                  .watch(lastTrendingDayLoadedProvider.notifier)
                                  .state = days,
                            );
                          }
                          if (episodes.isEmpty) return const SizedBox.shrink();
                          final trending = feedController.trending;
                          var section = TrendingSection(days.daysAgo());
                          if (trending.contains(section)) {
                            section = trending.firstWhere((s) => s == section);
                          } else {
                            trending.add(section);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (user.lastListened != null ||
                                  user.favPodcasts.isNotEmpty ||
                                  trending.first != section)
                                FeedTitle(
                                  section.title,
                                  textKey: section.key,
                                ),
                              for (var i = 0; i < episodes.length; i++)
                                Consumer(
                                  builder: (context, ref, _) {
                                    final podcastValue = ref.watch(
                                        podcastFutureProvider(
                                            episodes[i].showId));
                                    return podcastValue.when(
                                        loading: () =>
                                            const SkeletonEpisodeCard(),
                                        error: (e, _) =>
                                            const SizedBox.shrink(),
                                        data: (podcast) {
                                          final card = EpisodeCard(
                                            episodes[i],
                                            podcast: podcast,
                                          );
                                          return card;
                                        });
                                  },
                                ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                childCount: 365,
              ),
            ),
            if (lastLoaded < 365 - 1)
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  child: const SizedBox.square(
                    dimension: kSmallIconSize,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),

            // so it doesnt end behind the bottom bar
            SliverToBoxAdapter(
              child: SizedBox(
                height: HomeScreen.bottomBarHeigh +
                    (isPlayerAlive ? Player.heightWithSpotify : 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
