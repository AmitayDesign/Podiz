import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/discussionAppBar.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/player/components/discussionSnackBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class DiscussionPage extends ConsumerStatefulWidget {
  static const route = '/discussionPage';
  DiscussionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends ConsumerState<DiscussionPage> {
  Duration position = Duration.zero;
  StreamSubscription<Duration>? subscription;

  @override
  void initState() {
    var player = ref.read(playerProvider);
    position = player.position;
    final playerManager = ref.read(playerManagerProvider);

    subscription = player.onAudioPositionChanged.listen((newPosition) {
      position = newPosition;
      playerManager.showComments(position.inMilliseconds);
    });

    super.initState();
  }

  @override
  void dispose() {
    subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("building discusion room");
    final comments = ref.watch(commentsStreamProvider);
    final player = ref.watch(playerStreamProvider);

    return player.maybeWhen(
      data: (p) {
        return comments.maybeWhen(
          data: (c) {
            print(c);
            // List<Comment> list = playerManager.showComments(position.inMilliseconds);
            return Scaffold(
              appBar: DiscussionAppBar(p.podcastPlaying),
              body: Column(children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: c.length,
                    itemBuilder: (context, index) =>
                        DiscussionCard(p.podcastPlaying!, c[index]),
                  ),
                ),
                DiscussionSnackBar(),
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
