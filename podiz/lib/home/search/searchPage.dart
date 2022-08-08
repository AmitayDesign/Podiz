import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterfire_ui/database.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/widgets/showSearchTile.dart';
import 'package:podiz/aspect/widgets/userSearchTile.dart';

import 'package:podiz/home/homePage.dart';
import 'package:podiz/aspect/widgets/podcastTile.dart';
import 'package:podiz/home/search/components/searchBar.dart';
import 'package:podiz/home/search/components/searchInSpotify.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/objects/user/User.dart';
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
  final searchController = TextEditingController(text: "");
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
    bool isEmpty = true;
    return player.maybeWhen(
      orElse: () => SplashScreen.error(),
      loading: () => SplashScreen(),
      data: (p) => Stack(
        children: [
          if (searchBarHeight != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 70)),
                  FirestoreQueryBuilder<SearchResult>(
                    query: FirebaseFirestore.instance
                        .collection("podcasts")
                        .where("searchArray",
                            arrayContains: query.toLowerCase())
                        .withConverter(fromFirestore: (podcast, _) {
                      Podcast p = Podcast.fromJson(podcast.data()!);
                      p.uid = podcast.id;
                      return podcastManager.podcastToSearchResult(p);
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
                            isEmpty = false;

                            SearchResult episode =
                                snapshot.docs[index].data() as SearchResult;
                            episode.uid = snapshot.docs[index].id;
                            return PodcastTile(episode,
                                isPlaying: p.podcastPlaying == null
                                    ? false
                                    : p.podcastPlaying!.uid == episode.uid);
                          },
                          childCount: snapshot.docs.length,
                        ),
                      );
                    },
                  ),
                  FirestoreQueryBuilder<Podcaster>(
                    query: FirebaseFirestore.instance
                        .collection("podcasters")
                        .where("searchArray",
                            arrayContains: query.toLowerCase())
                        .withConverter(fromFirestore: (show, _) {
                      Podcaster s = Podcaster.fromJson(show.data()!);
                      s.uid = show.id;
                      return s;
                    }, toFirestore: (show, _) {
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
                            isEmpty = false;

                            Podcaster show =
                                snapshot.docs[index].data() as Podcaster;
                            show.uid = snapshot.docs[index].id;

                            return ShowSearchTile(show);
                          },
                          childCount: snapshot.docs.length,
                        ),
                      );
                    },
                  ),
                  FirestoreQueryBuilder<UserPodiz>(
                    query: FirebaseFirestore.instance
                        .collection("users")
                        .where("searchArray",
                            arrayContains: query.toLowerCase())
                        .withConverter(fromFirestore: (user, _) {
                      UserPodiz u = UserPodiz.fromJson(user.data()!);
                      u.uid = user.id;
                      isEmpty = false;
                      return u;
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

                            UserPodiz user =
                                snapshot.docs[index].data() as UserPodiz;
                            user.uid = snapshot.docs[index].id;

                            return UserSeachTile(user);
                          },
                          childCount: snapshot.docs.length,
                        ),
                      );
                    },
                  ),
                  if (isEmpty && query.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: SearchInSpotify(query),
                    )
                  ]
                ],
              ),
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
