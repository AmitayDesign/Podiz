import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/widgets/gradientAppBar.dart';
import 'package:podiz/aspect/widgets/showSearchTile.dart';
import 'package:podiz/aspect/widgets/sliverFirestoreQueryBuilder.dart';
import 'package:podiz/aspect/widgets/userSearchTile.dart';
import 'package:podiz/home/search/components/searchBar.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/show.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_Card.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/routing/app_router.dart';

import 'components/spotifySearch.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final searchController = TextEditingController();
  String get query => searchController.text;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openEpisode(Podcast podcast) {
    ref.read(playerRepositoryProvider).play(podcast.uid!); //!
    context.goNamed(
      AppRoute.discussion.name,
      params: {'episodeId': podcast.uid!},
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
    final userManager = ref.watch(userManagerProvider);
    final podcastManager = ref.watch(podcastManagerProvider);
    final showManager = ref.watch(showManagerProvider);
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: SearchBar(controller: searchController),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ValueListenableBuilder(
            valueListenable: searchController,
            builder: (context, value, _) {
              return CustomScrollView(
                slivers: [
                  // so it doesnt start behind the app bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: GradientAppBar.backgroundHeight),
                  ),

                  SliverFirestoreQueryBuilder<UserPodiz>(
                    query: userManager.usersFirestoreQuery(query),
                    builder: (context, user) => UserSearchTile(user), //!
                  ),
                  SliverFirestoreQueryBuilder<Show>(
                    query: showManager.showsFirestoreQuery(query),
                    builder: (context, podcast) => ShowSearchTile(podcast), //!
                  ),
                  SliverFirestoreQueryBuilder<Podcast>(
                    query: podcastManager.podcastsFirestoreQuery(query),
                    builder: (context, episode) => EpisodeCard(
                      episode,
                      onTap: () => openEpisode(episode),
                      onPodcastTap: () => openPodcast(episode),
                    ),
                  ),

                  if (query.isNotEmpty)
                    SliverToBoxAdapter(child: SpotifySearch(query)),

                  // so it doesnt end behind the bottom bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: HomeScreen.bottomBarHeigh),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
