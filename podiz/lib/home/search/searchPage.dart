import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:podiz/aspect/widgets/podcastTile.dart';
import 'package:podiz/aspect/widgets/showSearchTile.dart';
import 'package:podiz/aspect/widgets/userSearchTile.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/search/components/searchBar.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/objects/show.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/providers.dart';

import 'components/searchInSpotify.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final searchController = TextEditingController(text: "")
    ..addListener(() => setState(() {}));

  final searchBarKey = GlobalKey();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String get query => searchController.text;

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerStreamProvider).valueOrNull;
    final isPlaying = player?.isPlaying ?? false;
    bool isEmpty = true;

    return Scaffold(
      appBar: SearchBar(controller: searchController),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            FirestoreQueryBuilder<SearchResult>(
              query: FirebaseFirestore.instance
                  .collection("podcasts")
                  .where("searchArray", arrayContains: query.toLowerCase())
                  .withConverter(
                    fromFirestore: (doc, _) {
                      Podcast podcast = Podcast.fromFirestore(doc);
                      return SearchResult.fromPodcast(podcast);
                    },
                    toFirestore: (podcast, _) => {},
                  ),
              builder: (context, snapshot, _) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      isEmpty = false;

                      final episode = snapshot.docs[index].data();
                      return PodcastTile(
                        episode,
                        isPlaying:
                            player?.podcast.uid == episode.uid && isPlaying,
                      );
                    },
                    childCount: snapshot.docs.length,
                  ),
                );
              },
            ),
            FirestoreQueryBuilder<Show>(
              query: FirebaseFirestore.instance
                  .collection("podcasters")
                  .where("searchArray", arrayContains: query.toLowerCase())
                  .withConverter(
                    fromFirestore: (show, _) => Show.fromFirestore(show),
                    toFirestore: (show, _) => {},
                  ),
              builder: (context, snapshot, _) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      isEmpty = false;

                      final show = snapshot.docs[index].data();
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
                  .where("searchArray", arrayContains: query.toLowerCase())
                  .withConverter(
                    fromFirestore: (user, _) => UserPodiz.fromFirestore(user),
                    toFirestore: (podcast, _) => {},
                  ),
              builder: (context, snapshot, _) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      isEmpty = false;

                      final user = snapshot.docs[index].data();
                      return UserSearchTile(user);
                    },
                    childCount: snapshot.docs.length,
                  ),
                );
              },
            ),
            if (isEmpty && query.isNotEmpty)
              SliverToBoxAdapter(child: SearchInSpotify(query)),
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
