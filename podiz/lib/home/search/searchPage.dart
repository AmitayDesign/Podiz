import 'package:after_layout/after_layout.dart';
import 'package:podiz/aspect/constants.dart';

import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/search/components/podcastTile.dart';
import 'package:podiz/home/search/components/searchBar.dart';
import 'package:podiz/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget with HomePageMixin {
  @override
  final String label = 'Search';
  @override
  final Widget icon = const Icon(Icons.search);
  @override
  final Widget activeIcon =
      const Icon(Icons.search, color: Color(0xFF6310BF));
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
  // List<ObjRestaurant> filter(List<ObjRestaurant> podcasts) => podcasts
  //     .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
  //     .toList();

  @override
  Widget build(BuildContext context) {
    // final podcasts = filter(ref.watch(podcastsProvider));
    final podcasts = [];
    
    return Stack(
      children: [
        if (searchBarHeight != null)
          podcasts.isEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: searchBarHeight! + 8).add(
                      EdgeInsets.symmetric(horizontal: kScreenPadding * 2)),
                  child: Text(
                    Locales.string(context, "search2") + ' \"$query\"',
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(top: searchBarHeight!),
                  itemCount: podcasts.length,
                  itemBuilder: (context, i) => PodcastTile(), //TODO podcasts[i]
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
    );
  }
}
