import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/sliver_firestore_query_builder.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/features/episodes/presentation/card/episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/card/skeleton_episode_card.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/features/search/presentation/search_bar.dart';
import 'package:podiz/src/features/search/presentation/skeleton_podcast_card.dart';
import 'package:podiz/src/utils/instances.dart';

import 'podcast_card.dart';
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
  void initState() {
    super.initState();
    searchController.addListener(() {
      final q = query;
      if (!queries.contains(q)) {
        queries.add(q);
        searchInSpotify(q);
      }
    });
  }

  //TODO put this in a repository
  bool isLoading = false;
  final queries = <String>{};
  Future<void> searchInSpotify(String query) async {
    setState(() => isLoading = true);
    final accessToken = await ref.read(spotifyApiProvider).getAccessToken();
    await ref
        .read(functionsProvider)
        .httpsCallable("fetchSpotifySearch")
        .call({'accessToken': accessToken, 'query': query}).whenComplete(() {
      if (mounted) setState(() => isLoading = false);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userRepository = ref.watch(userRepositoryProvider);
    final episodeRepository = ref.watch(episodeRepositoryProvider);
    final podcastRepository = ref.watch(podcastRepositoryProvider);
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: SearchBar(controller: searchController),
        body: ValueListenableBuilder(
          valueListenable: searchController,
          builder: (context, value, _) {
            return CustomScrollView(
              slivers: [
                // so it doesnt start behind the app bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: GradientBar.backgroundHeight + 16),
                ),

                if (query.isEmpty) ...[
                  if (user.favPodcasts.isNotEmpty)
                    SliverList(
                      delegate: SliverChildListDelegate([
                        for (final podcastId in user.favPodcasts)
                          Consumer(builder: (context, ref, _) {
                            final podcastValue =
                                ref.watch(podcastFutureProvider(podcastId));
                            return podcastValue.when(
                                loading: () => const SkeletonPodcastCard(),
                                error: (e, _) => const SizedBox.shrink(),
                                data: (podcast) => PodcastCard(podcast));
                          }),
                      ]),
                    )
                ] else ...[
                  SliverFirestoreQueryBuilder<UserPodiz>(
                    query: userRepository.usersFirestoreQuery(query),
                    builder: (context, user) => UserCard(user),
                  ),
                  SliverFirestoreQueryBuilder<Podcast>(
                    query: podcastRepository.podcastsFirestoreQuery(query),
                    builder: (context, podcast) => PodcastCard(podcast),
                  ),
                  SliverFirestoreQueryBuilder<Episode>(
                    query: episodeRepository.episodesFirestoreQuery(query),
                    builder: (context, episode) {
                      return Consumer(
                        builder: (context, ref, _) {
                          final podcastValue =
                              ref.watch(podcastFutureProvider(episode.showId));
                          return podcastValue.when(
                              loading: () => const SkeletonEpisodeCard(),
                              error: (e, _) => const SizedBox.shrink(),
                              data: (podcast) {
                                return EpisodeCard(
                                  episode,
                                  podcast: podcast,
                                  insights: false,
                                );
                              });
                        },
                      );
                    },
                  ),
                  if (isLoading)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: const SizedBox.square(
                          dimension: kSmallIconSize,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                    ),
                  // SliverToBoxAdapter(child: SpotifySearchButton(query)),
                ],

                // so it doesnt end behind the bottom bar
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: HomeScreen.bottomBarHeigh + Player.height,
                  ),
                ),
              ],
            );
          },
        ));
  }
}
