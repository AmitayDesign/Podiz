import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/feed/components/feedAppBar.dart';
import 'package:podiz/home/feed/components/feedTitle.dart';
import 'package:podiz/home/feed/components/podcastCard.dart';
import 'package:podiz/home/feed/components/quickNoteButton.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/loading.dart/episodeLoading.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/providers.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  late final scrollController = ScrollController()..addListener(handleAppBar);

  final myCastsKey = GlobalKey();
  final hotliveKey = GlobalKey();
  final queryFeed = FirebaseFirestore.instance
      .collection("podcasts")
      .orderBy("release_date", descending: true)
      .withConverter(
        fromFirestore: (doc, _) => Podcast.fromFirestore(doc),
        toFirestore: (podcast, _) => {},
      );

  void handleAppBar() {
    final user = ref.read(currentUserProvider);
    final myCastsPosition = myCastsKey.offset?.dy;
    final hotlivePosition = hotliveKey.offset?.dy;

    final myCastsDidNotPass = user.favPodcasts.isEmpty ||
        (myCastsPosition != null && myCastsPosition > FeedAppBar.height);
    final hotliveDidNotPass =
        hotlivePosition != null && hotlivePosition > FeedAppBar.height;

    late final String title;
    if (user.lastListened.isNotEmpty &&
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
    context.pushNamed(
      AppRoute.discussion.name,
      params: {'showId': podcast.show_uri},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final authManager = ref.watch(authManagerProvider);
    final lastPodcastValue = ref.watch(lastListenedEpisodeFutureProvider);
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
              child: SizedBox(height: FeedAppBar.backgroundHeight),
            ),

            //* Last Listened
            if (user.lastListened.isNotEmpty) //!
              SliverToBoxAdapter(
                child: lastPodcastValue.when(
                  loading: () => const EpisodeLoading(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (lastPodcast) => PodcastCard(
                    lastPodcast,
                    bottom: QuickNoteButton(podcast: lastPodcast),
                  ),
                ),
              ),

            //* My Casts
            if (user.favPodcasts.isNotEmpty)
              SliverList(
                delegate: SliverChildListDelegate([
                  if (user.lastListened.isNotEmpty)
                    FeedTile(
                      Locales.string(context, "mycasts"),
                      key: hotliveKey,
                    ),
                  for (final podcast in authManager.myCast)
                    PodcastCard(
                      podcast,
                      onTap: () => openPodcast(podcast),
                    ),
                ]),
              ),

            //* Hot & Live
            if (user.lastListened.isNotEmpty || user.favPodcasts.isNotEmpty)
              SliverFeedTile(
                Locales.string(context, "hotlive"),
                key: hotliveKey,
              ),
            FirestoreQueryBuilder<Podcast>(
              query: queryFeed,
              builder: (context, snapshot, _) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      final podcast = snapshot.docs[index].data();
                      podcast.uid = snapshot.docs[index].id;
                      return PodcastCard(
                        podcast,
                        onTap: () => openPodcast(podcast),
                      );
                    },
                    childCount: snapshot.docs.length,
                  ),
                );
              },
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
