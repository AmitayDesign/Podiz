import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/sliver_firestore_query_builder.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/search/presentation/search_bar.dart';
import 'package:podiz/src/routing/app_router.dart';

import 'podcast_card.dart';
import 'spotify_search_button.dart';
import 'user_card.dart';

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
      AppRoute.podcast.name,
      params: {'podcastId': episode.showId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final userManager = ref.watch(userManagerProvider);
    final episoddeRepository = ref.watch(episodeRepositoryProvider);
    final podcastRepository = ref.watch(podcastRepositoryProvider);
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
                    child: SizedBox(height: GradientBar.backgroundHeight + 16),
                  ),

                  SliverFirestoreQueryBuilder<UserPodiz>(
                    query: userManager.usersFirestoreQuery(query),
                    builder: (context, user) => UserCard(user),
                  ),
                  SliverFirestoreQueryBuilder<Podcast>(
                    query: podcastRepository.podcastsFirestoreQuery(query),
                    builder: (context, podcast) => PodcastCard(podcast),
                  ),
                  SliverFirestoreQueryBuilder<Episode>(
                    query: episoddeRepository.episodesFirestoreQuery(query),
                    builder: (context, episode) => EpisodeCard(
                      episode,
                      insights: false,
                    ),
                  ),

                  if (query.isNotEmpty)
                    SliverToBoxAdapter(child: SpotifySearchButton(query)),

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
