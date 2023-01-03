import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/sliver_firestore_query_builder.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/card/quick_note_button.dart';
import 'package:podiz/src/features/episodes/presentation/card/skeleton_episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/features/showcase/presentation/package_files/showcase_widget.dart';
import 'package:podiz/src/features/showcase/presentation/showcase_step.dart';

import 'feed_bar.dart';
import 'feed_controller.dart';
import 'feed_title.dart';

class FeedPage extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  const FeedPage({Key? key, this.scrollController}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

/// Use the [AutomaticKeepAliveClientMixin] to keep the state.
class _FeedPageState extends ConsumerState<FeedPage>
    with AutomaticKeepAliveClientMixin {
  late final scrollController = (widget.scrollController ?? ScrollController())
    ..addListener(
      () => ref.read(feedControllerProvider.notifier).handleTitles(),
    );

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    if (widget.scrollController == null) scrollController.dispose();
    super.dispose();
  }

  Widget showcase({required String podcastTitle, required EpisodeCard child}) =>
      ShowcaseStep(
        step: 1,
        onTap: () {
          child.openEpisode(context, ref.read);
          ShowCaseWidget.of(context).next();
        },
        onNext: () => child.openEpisode(context, ref.read),
        title: 'Open a podcast you like',
        description: '$podcastTitle could be a great option to start with',
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    // call 'super.build' when using 'AutomaticKeepAliveClientMixin'
    super.build(context);

    final user = ref.watch(currentUserProvider);
    final episodeRepository = ref.watch(episodeRepositoryProvider);
    final feedController = ref.read(feedControllerProvider.notifier);

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
                SliverFeedTitle(
                  Locales.string(context, feedController.myCastsLocaleKey),
                  textKey: feedController.myCastsKey,
                ),
              SliverList(
                delegate: SliverChildListDelegate([
                  for (final podcastId in user.favPodcasts.take(6))
                    Consumer(builder: (context, ref, _) {
                      final podcastValue =
                          ref.watch(podcastFutureProvider(podcastId));
                      return podcastValue.when(
                          loading: () => const SkeletonEpisodeCard(),
                          error: (e, _) => const SizedBox.shrink(),
                          data: (podcast) {
                            final lastEpisodeValue = ref.watch(
                                lastShowEpisodeFutureProvider(podcastId));
                            return lastEpisodeValue.when(
                                loading: () => const SkeletonEpisodeCard(),
                                error: (e, _) => const SizedBox.shrink(),
                                data: (lastEpisode) {
                                  if (lastEpisode == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final card = EpisodeCard(
                                    lastEpisode,
                                    podcast: podcast,
                                  );
                                  return podcastId == user.favPodcasts.first
                                      ? showcase(
                                          podcastTitle: podcast.name,
                                          child: card,
                                        )
                                      : card;
                                });
                          });
                    }),
                ]),
              ),
            ],

            //* Hot & Live
            if (user.lastListened != null || user.favPodcasts.isNotEmpty)
              SliverFeedTitle(
                Locales.string(context, feedController.hotLiveLocaleKey),
                textKey: feedController.hotLiveKey,
              ),
            SliverFirestoreQueryBuilder<Episode>(
              query: episodeRepository.hotliveFirestoreQuery(),
              indexedBuilder: (context, episode, i) {
                return Consumer(
                  builder: (context, ref, _) {
                    final podcastValue =
                        ref.watch(podcastFutureProvider(episode.showId));
                    return podcastValue.when(
                        loading: () => const SkeletonEpisodeCard(),
                        error: (e, _) => const SizedBox.shrink(),
                        data: (podcast) {
                          final card = EpisodeCard(episode, podcast: podcast);
                          return i == 0 && user.favPodcasts.isEmpty
                              ? showcase(
                                  podcastTitle: podcast.name,
                                  child: card,
                                )
                              : card;
                        });
                  },
                );
              },
            ),
            SliverFirestoreQueryBuilder<Episode>(
              query: episodeRepository.hotliveFirestoreQueryRemainig(),
              indexedBuilder: (context, episode, i) {
                return Consumer(
                  builder: (context, ref, _) {
                    final podcastValue =
                        ref.watch(podcastFutureProvider(episode.showId));
                    return podcastValue.when(
                        loading: () => const SkeletonEpisodeCard(),
                        error: (e, _) => const SizedBox.shrink(),
                        data: (podcast) {
                          final card = EpisodeCard(episode, podcast: podcast);
                          return i == 0 && user.favPodcasts.isEmpty
                              ? showcase(
                                  podcastTitle: podcast.name,
                                  child: card,
                                )
                              : card;
                        });
                  },
                );
              },
            ),

            // so it doesnt end behind the bottom bar
            const SliverToBoxAdapter(
              child: SizedBox(
                height: HomeScreen.bottomBarHeigh + Player.heightWithSpotify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
