import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/home/components/followShowButton.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/search/components/podcastShowTile.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/loading.dart/episodeLoading.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/playerWidget.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class ShowPage extends ConsumerWidget {
  final String showId;
  const ShowPage(this.showId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showValue = ref.watch(showFutureProvider(showId));
    final podcastManager = ref.watch(podcastManagerProvider);
    //TODO put a stream in where for the show
    final player = ref.watch(playerStreamProvider);
    return showValue.when(
      error: (e, _) {
        print('showPage show: ${e.toString()}');
        return SplashScreen.error();
      },
      loading: () => SplashScreen(),
      data: (show) => player.when(
        error: (e, _) {
          print('showPage player: ${e.toString()}');
          return SplashScreen.error();
        },
        loading: () => SplashScreen(),
        data: (p) => Scaffold(
          appBar: BackAppBar(),
          body: Column(
            children: [
              //TODO SliverAppBar
              PodcastAvatar(imageUrl: show.image_url, size: 124),
              const SizedBox(height: 16),
              Text(
                show.name,
                style: context.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "${show.followers.length} Following",
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Consumer(
                          builder: (context, ref, _) {
                            final podcastId = show.podcasts[i];
                            final podcastValue =
                                ref.watch(podcastProvider(podcastId));
                            return podcastValue.when(
                                loading: () => const EpisodeLoading(),
                                error: (e, _) => Center(
                                      child: Text(
                                        '$e occurred',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                data: (podcast) {
                                  final searchResult = podcastManager
                                      .podcastToSearchResult(podcast);
                                  return PodcastShowTile(
                                    searchResult,
                                    isPlaying: p.podcastPlaying == null
                                        ? false
                                        : p.podcastPlaying!.uid == podcast.uid,
                                  );
                                });
                          },
                        ),
                        childCount: show.total_episodes,
                      ),
                      // p.getState != PlayerState.close
                      //     ? const Positioned(
                      //         bottom: 0.0,
                      //         left: 0.0,
                      //         right: 0.0,
                      //         child: PlayerWidget(),
                      //       )
                      //     : Container(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FollowShowButton(
            show.uid!,
            imageUrl: show.image_url,
            isPlaying: p.getState != PlayerState.close,
          ),
          bottomNavigationBar:
              p.getState == PlayerState.close ? null : const PlayerWidget(),
        ),
      ),
    );
  }
}
