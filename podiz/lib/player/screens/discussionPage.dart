import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/discussionAppBar.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/player/components/discussionSnackBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class DiscussionPage extends ConsumerStatefulWidget {
  DiscussionPage({Key? key}) : super(key: key);
  static const route = '/discussion';

  @override
  ConsumerState<DiscussionPage> createState() => _DiscussionPageState();
}
class _DiscussionPageState extends ConsumerState<DiscussionPage> {

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print("building discusion room");
    final PlayerManager playerManager = ref.read(playerManagerProvider);
    final comments = ref.watch(commentsStreamProvider);
    final player = ref.watch(playerStreamProvider);
    return player.maybeWhen(
      data: (p) {
        return comments.maybeWhen(
          data: (c) {
            c = playerManager.showComments(p.position.inMilliseconds);
            return Scaffold(
              appBar: DiscussionAppBar(p),
              body: Column(children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: c.length,
                    itemBuilder: (context, index) => DiscussionCard(p.podcastPlaying!, c[index]),
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
