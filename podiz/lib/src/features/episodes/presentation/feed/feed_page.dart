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

import 'feed_bar.dart';
import 'feed_controller.dart';
import 'feed_title.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

/// Use the [AutomaticKeepAliveClientMixin] to keep the state.
class _FeedPageState extends ConsumerState<FeedPage>
    with AutomaticKeepAliveClientMixin {
  late final scrollController = ScrollController()
    ..addListener(
      () => ref.read(feedControllerProvider.notifier).handleTitles(),
    );

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // call 'super.build' when using 'AutomaticKeepAliveClientMixin'
    super.build(context);

    final user = ref.watch(currentUserProvider);
    final episodeRepository = ref.watch(episodeRepositoryProvider);
    final feedController = ref.read(feedControllerProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const FeedBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
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
                            });
                      },
                    ),
                  );
                },
              ),

            //* My Casts
            // if (user.favPodcasts.isNotEmpty)
            //   SliverList(
            //     delegate: SliverChildListDelegate([
            //       if (user.lastListened.isNotEmpty)
            //         FeedTile(
            //           Locales.string(context, feedController.myCastsLocaleKey),
            //           textKey: feedController.myCastsKey,
            //         ),
            //       for (final episode in authManager.myCast)
            //         EpisodeCard(episode),
            //     ]),
            //   ),

            //* Hot & Live
            if (user.lastListened != null || user.favPodcasts.isNotEmpty)
              SliverFeedTile(
                Locales.string(context, feedController.hotLiveLocaleKey),
                textKey: feedController.hotLiveKey,
              ),
            SliverFirestoreQueryBuilder<Episode>(
              query: episodeRepository.hotliveFirestoreQuery(),
              builder: (context, episode) {
                return Consumer(
                  builder: (context, ref, _) {
                    final podcastValue =
                        ref.watch(podcastFutureProvider(episode.showId));
                    return podcastValue.when(
                        loading: () => const SkeletonEpisodeCard(),
                        error: (e, _) => const SizedBox.shrink(),
                        data: (podcast) {
                          return EpisodeCard(episode, podcast: podcast);
                        });
                  },
                );
              },
            ),

            // so it doesnt end behind the bottom bar
            const SliverToBoxAdapter(
              child: SizedBox(
                height: HomeScreen.bottomBarHeigh + Player.height,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
