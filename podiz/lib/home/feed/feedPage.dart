import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/gradientAppBar.dart';
import 'package:podiz/aspect/widgets/sliverFirestoreQueryBuilder.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/providers.dart';

import 'components/feedAppBar.dart';
import 'components/feedTitle.dart';
import 'components/podcastCard.dart';
import 'components/quickNoteButton.dart';
import 'components/skeletonPodcastCard.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  late final scrollController = ScrollController()..addListener(handleAppBar);

  final myCastsKey = GlobalKey();
  final hotliveKey = GlobalKey();

  void handleAppBar() {
    final user = ref.read(currentUserProvider);
    final myCastsPosition = myCastsKey.offset?.dy;
    final hotlivePosition = hotliveKey.offset?.dy;
    final lastPodcastValue = ref.read(lastListenedPodcastStreamProvider);

    final lastPodcastExists =
        lastPodcastValue.isLoading || lastPodcastValue.valueOrNull != null;
    final myCastsDidNotPass = user.favPodcasts.isEmpty ||
        (myCastsPosition != null && myCastsPosition > GradientAppBar.height);
    final hotliveDidNotPass =
        hotlivePosition != null && hotlivePosition > GradientAppBar.height;

    late final String title;
    if (lastPodcastExists &&
        user.lastListened.isNotEmpty &&
        myCastsDidNotPass &&
        hotliveDidNotPass) {
      title = 'lastListened';
    } else if (user.favPodcasts.isNotEmpty && hotliveDidNotPass) {
      title = 'myCasts';
    } else {
      title = 'hotlive';
    }

    ref.read(homeBarTitleProvider.notifier).state = title;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void openPodcast(Podcast podcast) {
    ref.read(playerManagerProvider).playEpisode(podcast, 0);
    context.goNamed(
      AppRoute.discussion.name,
      params: {'showId': podcast.show_uri},
    );
  }

  void openShow(Podcast podcast) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': podcast.show_uri},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final authManager = ref.watch(authManagerProvider);
    final lastPodcastValue = ref.watch(lastListenedPodcastStreamProvider);
    final podcastManager = ref.watch(podcastManagerProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const FeedAppBar(),
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
                loading: () => const SkeletonPodcastCard(
                  bottomHeight: QuickNoteButton.height,
                ),
                error: (e, _) => null,
                data: (lastPodcast) {
                  if (lastPodcast == null) return null;
                  return PodcastCard(
                    lastPodcast,
                    bottom: QuickNoteButton(podcast: lastPodcast),
                  );
                },
              ),
            ),

            //* My Casts
            if (user.favPodcasts.isNotEmpty)
              SliverList(
                delegate: SliverChildListDelegate([
                  if (user.lastListened.isNotEmpty)
                    FeedTile(
                      Locales.string(context, "mycasts"),
                      textKey: hotliveKey,
                    ),
                  for (final podcast in authManager.myCast)
                    PodcastCard(
                      podcast,
                      onTap: () => openPodcast(podcast),
                      onShowTap: () => openShow(podcast),
                    ),
                ]),
              ),

            //* Hot & Live
            if (user.lastListened.isNotEmpty || user.favPodcasts.isNotEmpty)
              SliverFeedTile(
                Locales.string(context, "hotlive"),
                textKey: hotliveKey,
              ),
            SliverFirestoreQueryBuilder<Podcast>(
              query: podcastManager.hotliveFirestoreQuery(),
              builder: (context, podcast) => PodcastCard(
                podcast,
                onTap: () => openPodcast(podcast),
                onShowTap: () => openShow(podcast),
              ),
            ),

            // so it doesnt end behind the bottom bar
            const SliverToBoxAdapter(
              child: SizedBox(height: HomePage.bottomBarHeigh),
            ),
          ],
        ),
      ),
    );
  }
}
