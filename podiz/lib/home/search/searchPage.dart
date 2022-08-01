import 'package:after_layout/after_layout.dart';
import 'package:podiz/aspect/constants.dart';

import 'package:podiz/home/homePage.dart';
import 'package:podiz/aspect/widgets/podcastTile.dart';
import 'package:podiz/home/search/components/searchBar.dart';
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
    searchController.addListener(() => setState(() {}));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() => searchBarHeight = searchBarKey.currentContext!.size!.height);
  }

  String get query => searchController.text;

  List<SearchResult> filterPodcast(
      Map<String, Podcast> podcasts, List<SearchResult> resultList) {
    podcasts.forEach(
      (_, value) {
        if (value.name.toLowerCase().contains(query.toLowerCase())) {
          resultList.add(SearchResult(
              uid: value.uid!,
              name: value.name,
              image_url: value.image_url,
              duration_ms: value.duration_ms,
              show_name: value.show_name,
              description: value.description,
              show_uri: value.show_uri,
              comments: value.comments,
              commentsImg: value.commentsImg,
              release_date: value.release_date,
              watching: value.watching));
        }
      },
    );
    return resultList;
  }

  List<SearchResult> filterPodcaster(
      List<Podcaster> podcasters, List<SearchResult> resultList) {
    for (Podcaster podcaster in podcasters) {
      if (podcaster.name.toLowerCase().contains(query.toLowerCase())) {
        resultList.add(SearchResult(
            uid: podcaster.uid!,
            name: podcaster.name,
            image_url: podcaster.image_url,
            publisher: podcaster.publisher,
            description: podcaster.description,
            total_episodes: podcaster.total_episodes,
            podcasts: podcaster.podcasts,
            followers: podcaster.followers));
      }
    }
    return resultList;
  }

  @override
  Widget build(BuildContext context) {
    List<SearchResult> result = [];
    result = filterPodcaster(ref.watch(showProvider), result);
    result = filterPodcast(ref.watch(podcastsProvider), result);
    final player = ref.watch(playerStreamProvider);
    return player.maybeWhen(
      orElse: () => SplashScreen.error(),
      loading: () => SplashScreen(),
      data: (p) => Stack(
        children: [
          if (searchBarHeight != null)
            result.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: searchBarHeight! + 8).add(
                        EdgeInsets.symmetric(horizontal: kScreenPadding * 2)),
                    child: Text(
                      Locales.string(context, "search2") + ' \"$query\"',
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                        top: searchBarHeight!, right: 16, left: 16),
                    itemCount: result.length,
                    itemBuilder: (context, i) => PodcastTile(result[i],
                        isPlaying: p.podcastPlaying == null
                            ? false
                            : p.podcastPlaying!.uid == result[i].uid),
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
