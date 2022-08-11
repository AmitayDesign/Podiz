import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/components/HomeAppBar.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/home/components/podcastListTile.dart';
import 'package:podiz/home/feed/components/podcastListTileQuickNote.dart';
import 'package:podiz/loading.dart/episodeLoading.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/providers.dart';

class FeedPage extends ConsumerStatefulWidget {
  final bool isPlaying;
  const FeedPage(this.isPlaying, {Key? key}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  late final _controller = ScrollController()..addListener(handleAppBar);

  final _controllerText = TextEditingController();

  final myCastsKey = GlobalKey();
  final hotliveKey = GlobalKey();

  double? positionFromKey(GlobalKey key) {
    final position = key.offset?.dy;
    if (position == null) return null;
    return position + key.size!.height;
  }

  void handleAppBar() {
    final myCastsPosition = myCastsKey.offset?.dy;
    final hotlivePosition = hotliveKey.offset?.dy;

    var title = ref.read(homeBarTitleProvider);

    if (hotlivePosition == null || hotlivePosition < HomeAppBar.height) {
      title = 'hotlive';
    } else if (myCastsPosition == null || myCastsPosition < HomeAppBar.height) {
      title = 'myCasts';
    } else {
      title = 'lastListened';
    }

    ref.read(homeBarTitleProvider.notifier).state = title;
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerText.dispose();
    super.dispose();
  }

  var queryFeed = FirebaseFirestore.instance
      .collection("podcasts")
      .orderBy("release_date", descending: true)
      .withConverter(
        fromFirestore: (doc, _) => Podcast.fromFirestore(doc),
        toFirestore: (podcast, _) => {},
      );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final authManager = ref.watch(authManagerProvider);
    final lastListenedEpisode = ref.watch(lastListenedEpisodeFutureProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const HomeAppBar(),
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: HomeAppBar.backgroundHeight),
          ),
          if (user.lastListened.isNotEmpty)
            SliverToBoxAdapter(
              child: lastListenedEpisode.when(
                loading: () => const EpisodeLoading(),
                error: (e, _) {
                  print(e);
                  return const SizedBox();
                },
                data: (ep) => PodcastListTileQuickNote(
                  ep,
                  quickNote: quickNote(ep, user),
                ),
              ),
            ),
          if (user.favPodcasts.isNotEmpty)
            SliverList(
              delegate: SliverChildListDelegate([
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Locales.string(context, "mycasts"),
                    style: podcastInsights(),
                    key: myCastsKey,
                  ),
                ),
                const SizedBox(height: 10),
                ...authManager.myCast.map((cast) => PodcastListTile(cast)),
              ]),
            ),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Locales.string(context, "hotlive"),
                style: podcastInsights(),
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
                    if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                      snapshot.fetchMore();
                    }

                    Podcast episode = snapshot.docs[index].data();
                    episode.uid = snapshot.docs[index].id;
                    return PodcastListTile(episode);
                  },
                  childCount: snapshot.docs.length,
                ),
              );
            },
          ),
        ],
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
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.edit,
              size: 16,
              color: Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 10),
            Text(Locales.string(context, "quicknote"),
                style: podcastArtistQuickNote()),
          ]),
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
                CircleProfile(user: user, size: 15.5),
                const SizedBox(width: 8),
                LimitedBox(
                  maxWidth: kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                  maxHeight: 31,
                  child: TextField(
                    // key: _key,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    controller: _controllerText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF262626),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      hintStyle: discussionSnackCommentHint(),
                      hintText: "Share your insight...",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    ref.read(authManagerProvider).doComment(
                        _controllerText.text,
                        episode.uid!,
                        episode.duration_ms);
                    _controllerText.clear();
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
                  style: discussionAppBarInsights(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
