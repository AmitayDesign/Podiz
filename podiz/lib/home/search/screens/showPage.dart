import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/search/components/podcastShowTile.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/objects/SearchResult.dart';
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
    final player = ref.watch(playerStreamProvider);
    return player.maybeWhen(
      orElse: () => SplashScreen.error(),
      loading: () => SplashScreen(),
      data: (p) => Scaffold(
        appBar: BackAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              PodcastAvatar(imageUrl: show.image_url, size: 124),
              const SizedBox(height: 16),
              Text(show.name, style: iconStyle()),
              const SizedBox(height: 8),
              Text("${show.followers.length} Following", style: showFollowing()),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: show.total_episodes,
                  itemBuilder: (context, i) {
                    SearchResult result =
                        podcastManager.getPodcastById(show.podcasts[i]);
                    if (result.name != "Not_Found") {
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
