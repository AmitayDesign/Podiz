import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterfire_ui/database.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:podiz/aspect/constants.dart';

import 'package:podiz/home/homePage.dart';
import 'package:podiz/aspect/widgets/podcastTile.dart';
import 'package:podiz/home/search/components/searchBar.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/splashScreen.dart';

class SearchPage extends ConsumerStatefulWidget with HomePageMixin {
  @override
  final String label = 'Search';
  @override
  final Widget icon = const Icon(Icons.search);
  @override
  final Widget activeIcon = const Icon(Icons.search);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> with AfterLayoutMixin {
  final searchController = TextEditingController();
  final searchBarKey = GlobalKey();
  double? searchBarHeight;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    print("habdleing");
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() => searchBarHeight = searchBarKey.currentContext!.size!.height);
  }

  String get query => searchController.text;

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerStreamProvider);
    final podcastManager = ref.watch(podcastManagerProvider);
    final showManager = ref.watch(showManagerProvider);
    return player.maybeWhen(
      orElse: () => SplashScreen.error(),
      loading: () => SplashScreen(),
      data: (p) => Stack(
        children: [
          if (searchBarHeight != null)
            CustomScrollView(
              slivers: [
                // FirestoreQueryBuilder<SearchResult>(
                //   query: FirebaseFirestore.instance
                //       .collection("podcasts")
                //       .where("name", isGreaterThanOrEqualTo: query)
                //       .withConverter(fromFirestore: (podcast, _) {
                //     Podcast p = Podcast.fromJson(podcast.data()!);
                //     p.uid = podcast.id;
                //     return podcastManager.podcastToSearchResult(p);
                //   }, toFirestore: (podcast, _) {
                //     return {};
                //   }),
                //   builder: (context, snapshot, _) {
                //     return SliverList(
                //       delegate: SliverChildBuilderDelegate(
                //         (context, index) {
                //           if (snapshot.hasMore &&
                //               index + 1 == snapshot.docs.length) {
                //             snapshot.fetchMore();
                //           }

                //           SearchResult episode =
                //               snapshot.docs[index].data() as SearchResult;
                //           episode.uid = snapshot.docs[index].id;
                //           if (!episode.name.contains(query)) {
                //             return Container();
                //           }
                //           return PodcastTile(episode,
                //               isPlaying: p.podcastPlaying == null
                //                   ? false
                //                   : p.podcastPlaying!.uid == episode.uid);
                //         },
                //         childCount: snapshot.docs.length,
                //       ),
                //     );
                //   },
                // ),
                FirestoreQueryBuilder<SearchResult>(
                  query: FirebaseFirestore.instance
                      .collection("podcasters")
                      .where("name", isGreaterThanOrEqualTo: query)
                      .withConverter(fromFirestore: (podcast, _) {
                    Podcaster p = Podcaster.fromJson(podcast.data()!);
                    p.uid = podcast.id;
                    return showManager.podcasterToSearchResult(p);
                  }, toFirestore: (podcast, _) {
                    return {};
                  }),
                  builder: (context, snapshot, _) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (snapshot.hasMore &&
                              index + 1 == snapshot.docs.length) {
                            snapshot.fetchMore();
                          }

                          SearchResult show =
                              snapshot.docs[index].data() as SearchResult;
                          show.uid = snapshot.docs[index].id;
                          if (!show.name.contains(query)) {
                            return Container();
                          }
                          return PodcastTile(show,
                              isPlaying: p.podcastPlaying == null
                                  ? false
                                  : p.podcastPlaying!.uid == show.uid);
                        },
                        childCount: snapshot.docs.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          Padding(
            key: searchBarKey,
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: kScreenPadding,
            ),
            child: SearchBar(controller: searchController),
          ),
        ],
      ),
    );
  }
}
