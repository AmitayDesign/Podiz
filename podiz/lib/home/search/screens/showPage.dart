import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/home/components/followShowButton.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/search/components/podcastShowTile.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/loading.dart/episodeLoading.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/playerWidget.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class ShowPage extends ConsumerWidget {
  static const route = '/showPage';

  final String showId;
  const ShowPage(this.showId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showValue = ref.watch(showFutureProvider(showId));
    final podcastManager = ref.watch(podcastManagerProvider);
    final player = ref
        .watch(playerStreamProvider); //TODO put a stream in where for the show
    return showValue.when(
      error: (e, _) => SplashScreen.error(),
      loading: () => SplashScreen(),
      data: (show) => player.when(
        error: (e, _) => SplashScreen.error(),
        loading: () => SplashScreen(),
        data: (p) => Scaffold(
          appBar: BackAppBar(),
          body: Stack(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  PodcastAvatar(imageUrl: show.image_url, size: 124),
                  const SizedBox(height: 16),
                  Text(show.name, style: context.textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text("${show.followers.length} Following",
                      style: context.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: show.total_episodes,
                      itemBuilder: (context, i) {
                        return FutureBuilder(
                            future: podcastManager
                                .getPodcastFromFirebase(show.podcasts[i]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                // If we got an error
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      '${snapshot.error} occurred',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  );

                                  // if we got our data
                                } else if (snapshot.hasData) {
                                  final podcast = snapshot.data as Podcast;
                                  return PodcastShowTile(
                                    podcastManager
                                        .podcastToSearchResult(podcast),
                                    isPlaying: p.podcastPlaying == null
                                        ? false
                                        : p.podcastPlaying!.uid == podcast.uid,
                                  );
                                }
                              }
                              return const EpisodeLoading();
                            });
                      },
                    ),
                  ),
                ],
              ),
            ),
            p.getState != PlayerState.close
                ? const Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: PlayerWidget(),
                  )
                : Container(),
          ]),
          floatingActionButton: FollowShowButton(
            show.uid!,
            imageUrl: show.image_url,
            isPlaying: p.getState != PlayerState.close,
          ),
        ),
      ),
    );
  }
}
