import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/followShowButton.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/search/components/podcastShowTile.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/objects/SearchResult.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/playerWidget.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class ShowPage extends ConsumerWidget {
  Podcaster show;

  ShowPage(this.show, {Key? key}) : super(key: key);
  static const route = '/showPage';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastManager = ref.read(podcastManagerProvider);
    final player = ref
        .watch(playerStreamProvider); //TODO put a stream in where for the show
    return player.maybeWhen(
      orElse: () => SplashScreen.error(),
      loading: () => SplashScreen(),
      data: (p) => Scaffold(
        appBar: BackAppBar(),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                children: [
                  PodcastAvatar(imageUrl: show.image_url, size: 124),
                  const SizedBox(height: 16),
                  Text(show.name, style: iconStyle()),
                  const SizedBox(height: 8),
                  Text("${show.followers.length} Following",
                      style: showFollowing()),
                  const SizedBox(height: 24),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: show.total_episodes,
                    itemBuilder: (context, i) {
                      SearchResult? result =
                          podcastManager.getSearchResultById(show.podcasts[i]);
                      if (result != null) {
                        return PodcastShowTile(
                          result,
                          isPlaying: p.podcastPlaying == null
                              ? false
                              : p.podcastPlaying!.uid == result.uid,
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          p.state != PlayerState.close
              ? Positioned(
                  child: PlayerWidget(),
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                )
              : Container(),
        ]),
        floatingActionButton: FollowShowButton(
          show.uid!,
          imageUrl: show.image_url,
          isPlaying: p.state != PlayerState.close,
        ),
      ),
    );
  }
}
