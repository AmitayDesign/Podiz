import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/widgets/gradientAppBar.dart';
import 'package:podiz/aspect/widgets/sliverFirestoreQueryBuilder.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart' hide currentUserProvider;
import 'package:podiz/src/features/auth/data/auth_repository.dart';
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
    ..addListener(ref.read(feedControllerProvider.notifier).handleTitles);

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void openEpisode(Podcast episode) {
    final playerRepository = ref.read(playerRepositoryProvider);
    playerRepository.currentPlayerState().then((player) {
      if (player?.episodeId != episode.uid!) {
        ref.read(playerRepositoryProvider).play(episode.uid!);
      }
    });
    context.goNamed(
      AppRoute.discussion.name,
      params: {'episodeId': episode.uid!},
    );
  }

  void openPodcast(Podcast podcast) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': podcast.show_uri},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final lastPodcastValue = ref.watch(lastListenedPodcastStreamProvider); //!
    final podcastManager = ref.watch(podcastManagerProvider); //!
    final controller = ref.read(feedControllerProvider.notifier);
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
              child: SizedBox(height: GradientAppBar.backgroundHeight),
            ),

            //* Last Listened
            SliverToBoxAdapter(
              child: lastPodcastValue.when(
                loading: () => const SkeletonEpisodeCard(
                  bottomHeight: QuickNoteButton.height,
                ),
                error: (e, _) => null,
                data: (lastPodcast) {
                  if (lastPodcast == null) return null;
                  return EpisodeCard(
                    lastPodcast,
                    onTap: () => openEpisode(lastPodcast),
                    onPodcastTap: () => openPodcast(lastPodcast),
                    bottom: QuickNoteButton(podcast: lastPodcast),
                  );
                },
              ),
            ),

            //* My Casts
            // if (user.favPodcastIds.isNotEmpty)
            //   SliverList(
            //     delegate: SliverChildListDelegate([
            //       if (user.lastPodcastId.isNotEmpty)
            //         FeedTile(
            //           Locales.string(context, controller.myCastsLocaleKey),
            //           textKey: controller.myCastsKey,
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
            if (user.lastPodcastId.isNotEmpty || user.favPodcastIds.isNotEmpty)
              SliverFeedTile(
                Locales.string(context, controller.hotLiveLocaleKey),
                textKey: controller.hotLiveKey,
              ),
            SliverFirestoreQueryBuilder<Podcast>(
              query: podcastManager.hotliveFirestoreQuery(),
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
