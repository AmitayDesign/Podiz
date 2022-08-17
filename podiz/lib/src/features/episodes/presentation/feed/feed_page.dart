import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/widgets/sliverFirestoreQueryBuilder.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/card/quick_note_button.dart';
import 'package:podiz/src/features/episodes/presentation/card/skeleton_episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/routing/app_router.dart';

import 'feed_bar.dart';
import 'feed_controller.dart';
import 'feed_title.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  late final scrollController = ScrollController()
    ..addListener(
      () => ref.read(feedControllerProvider.notifier).handleTitles(),
    );

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void openEpisode(Episode episode) {
    // just call play() if the episode is NOT playing
    ref.read(playerRepositoryProvider).fetchPlayingEpisode().then(
      (playingEpisode) {
        if (playingEpisode?.id != episode.id) {
          ref.read(playerRepositoryProvider).play(episode.id);
        }
      },
    );
    context.goNamed(
      AppRoute.discussion.name,
      params: {'episodeId': episode.id},
    );
  }

  void openPodcast(Episode episode) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': episode.showId},
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: SizedBox(height: GradientBar.backgroundHeight),
            ),

            //* Last Listened
            if (user.lastListenedEpisodeId.isNotEmpty)
              Consumer(
                builder: (context, ref, _) {
                  final lastListenedValue = ref
                      .watch(episodeFutureProvider(user.lastListenedEpisodeId));
                  return SliverToBoxAdapter(
                    child: lastListenedValue.when(
                      loading: () => const SkeletonEpisodeCard(
                        bottomHeight: QuickNoteButton.height,
                      ),
                      error: (e, _) => null,
                      data: (lastListened) {
                        return EpisodeCard(
                          lastListened,
                          onTap: () => openEpisode(lastListened),
                          onPodcastTap: () => openPodcast(lastListened),
                          bottom: QuickNoteButton(episode: lastListened),
                        );
                      },
                    ),
                  );
                },
              ),

            //* My Casts
            // if (user.favPodcastIds.isNotEmpty)
            //   SliverList(
            //     delegate: SliverChildListDelegate([
            //       if (user.lastListenedEpisodeId.isNotEmpty)
            //         FeedTile(
            //           Locales.string(context, feedController.myCastsLocaleKey),
            //           textKey: feedController.myCastsKey,
            //         ),
            //       for (final podcast in authManager.myCast)
            //         EpisodeCard(
            //           podcast,
            //           onTap: () => openEpisode(podcast),
            //           onPodcastTap: () => openPodcast(podcast),
            //         ),
            //     ]),
            //   ),

            //* Hot & Live
            if (user.lastListenedEpisodeId.isNotEmpty ||
                user.favPodcastIds.isNotEmpty)
              SliverFeedTile(
                Locales.string(context, feedController.hotLiveLocaleKey),
                textKey: feedController.hotLiveKey,
              ),
            SliverFirestoreQueryBuilder<Episode>(
              query: episodeRepository.hotliveFirestoreQuery(),
              builder: (context, podcast) => EpisodeCard(
                podcast,
                onTap: () => openEpisode(podcast),
                onPodcastTap: () => openPodcast(podcast),
              ),
            ),

            // so it doesnt end behind the bottom bar
            const SliverToBoxAdapter(
              child: SizedBox(height: HomeScreen.bottomBarHeigh),
            ),
          ],
        ),
      ),
    );
  }
}
