import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/components/profileAvatar.dart';
import 'package:podiz/home/feed/components/feedAppBar.dart';
import 'package:podiz/home/feed/components/podcastCard.dart';
import 'package:podiz/home/feed/components/podcastListTileQuickNote.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/loading.dart/episodeLoading.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/providers.dart';

class FeedPage extends ConsumerStatefulWidget {
  final bool isPlaying;
  const FeedPage(this.isPlaying, {Key? key}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  late final scrollController = ScrollController()..addListener(handleAppBar);
  final textController = TextEditingController();
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

    late final String title;
    if (user.lastListened.isNotEmpty &&
        myCastsPosition != null &&
        myCastsPosition > FeedAppBar.height) {
      title = 'lastListened';
    } else if (user.favPodcasts.isNotEmpty &&
        hotlivePosition != null &&
        hotlivePosition > FeedAppBar.height) {
      title = 'muCasts';
    } else {
      title = 'hotlive';
    }

    ref.read(homeBarTitleProvider.notifier).state = title;
  }

  @override
  void dispose() {
    scrollController.dispose();
    textController.dispose();
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
            if (user.lastListened.isNotEmpty)
              SliverToBoxAdapter(
                child: lastPodcastValue.when(
                  loading: () => const EpisodeLoading(),
                  error: (e, _) {
                    print(e);
                    return const SizedBox();
                  },
                  data: (lastPodcast) => PodcastListTileQuickNote(
                    lastPodcast,
                    quickNote: quickNote(lastPodcast, user),
                  ),
                ),
              ),
            if (user.favPodcasts.isNotEmpty)
              SliverList(
                delegate: SliverChildListDelegate([
                  if (user.lastListened.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Locales.string(context, "mycasts"),
                        style: context.textTheme.bodyLarge,
                        key: myCastsKey,
                      ),
                    ),
                  const SizedBox(height: 10),
                  ...authManager.myCast.map((cast) =>
                      PodcastCard(cast, onTap: () => openPodcast(cast))),
                ]),
              ),
            if (user.lastListened.isNotEmpty || user.favPodcasts.isNotEmpty)
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Locales.string(context, "hotlive"),
                    style: context.textTheme.bodyLarge,
                    key: hotliveKey,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
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

                      Podcast episode = snapshot.docs[index].data();
                      episode.uid = snapshot.docs[index].id;
                      return PodcastCard(
                        episode,
                        onTap: () => openPodcast(episode),
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

  Widget quickNote(Podcast episode, UserPodiz user) {
    return Container(
      height: 31,
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.edit,
                size: 16,
                color: Color(0xFF9E9E9E),
              ),
              const SizedBox(width: 10),
              Text(
                Locales.string(context, "quicknote"),
                style: context.textTheme.bodyMedium!.copyWith(
                  color: Palette.grey600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: const Color(0xFF4E4E4E),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              builder: (context) => commentView(episode, user),
            );
          }),
    );
  }

  Widget commentView(Podcast episode, UserPodiz user) {
    return Container(
      height: 127,
      decoration: const BoxDecoration(
        color: Color(0xFF4E4E4E),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                ProfileAvatar(user: user, radius: 15.5),
                const SizedBox(width: 8),
                LimitedBox(
                  maxWidth: kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                  maxHeight: 31,
                  child: TextField(
                    // key: _key,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    controller: textController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF262626),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      hintStyle: context.textTheme.bodySmall!.copyWith(
                        color: Palette.white90,
                      ),
                      hintText: "Share your insight...",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    ref.read(authManagerProvider).doComment(
                        textController.text, episode.uid!, episode.duration_ms);
                    textController.clear();
                  },
                  child: const Icon(
                    Icons.send,
                    size: 31,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  "${episode.watching} listening right now",
                  style: context.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
