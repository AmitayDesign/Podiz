import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/discussionAppBar.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/player/components/discussionSnackBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class DiscussionPage extends ConsumerWidget {
  DiscussionPage({Key? key}) : super(key: key);
  static const route = '/discussion';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("building discusion room");
    final comments = ref.watch(commentsStreamProvider);
    final player = ref.watch(playerStreamProvider);
    final playerManager = ref.read(playerManagerProvider);
    return player.maybeWhen(
      data: (p) {
        return comments.maybeWhen(
          data: (c) {
            // c = playerManager.showComments(p.position.inMilliseconds);
            List<Comment> list =
                playerManager.showComments(p.position.inMilliseconds);
            return Scaffold(
              appBar: DiscussionAppBar(p.podcastPlaying!),
              body: Column(children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: c.length,
                    itemBuilder: (context, index) =>
                        DiscussionCard(p.podcastPlaying!, list[index]),
                  ),
                ),
                DiscussionSnackBar(p),
              ]),
            );
          },
          loading: () => const CircularProgressIndicator(),
          orElse: () => SplashScreen.error(),
        );
      },
      loading: () => const CircularProgressIndicator(),
      orElse: () => SplashScreen.error(),
    );
  }
}
