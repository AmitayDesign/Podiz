import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/widgets/showSearchTile.dart';
import 'package:podiz/aspect/widgets/sliverFirestoreQueryBuilder.dart';
import 'package:podiz/aspect/widgets/userSearchTile.dart';
import 'package:podiz/home/search/components/searchBar.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/show.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
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

  void openEpisode(Episode episode) {
    ref.read(playerRepositoryProvider).play(episode.id); //!
    context.goNamed(
      AppRoute.discussion.name,
      params: {'episodeId': episode.id},
    );
  }

  void openPodcast(Episode episode) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': episode.showId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final userManager = ref.watch(userManagerProvider);
    final episoddeRepository = ref.watch(episodeRepositoryProvider);
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
                    child: SizedBox(height: GradientBar.backgroundHeight),
                  ),

                  SliverFirestoreQueryBuilder<UserPodiz>(
                    query: userManager.usersFirestoreQuery(query),
                    builder: (context, user) => UserSearchTile(user), //!
                  ),
                  SliverFirestoreQueryBuilder<Show>(
                    query: showManager.showsFirestoreQuery(query),
                    builder: (context, podcast) => ShowSearchTile(podcast), //!
                  ),
                  SliverFirestoreQueryBuilder<Episode>(
                    query: episoddeRepository.episodesFirestoreQuery(query),
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
