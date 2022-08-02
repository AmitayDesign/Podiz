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
    position = player.timer.position;
    final playerManager = ref.read(playerManagerProvider);

    subscription = player.timer.onAudioPositionChanged.listen((newPosition) {
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
    final comments = ref.watch(commentsStreamProvider);
    return comments.maybeWhen(
      data: (c) {
        return Scaffold(
          appBar: DiscussionAppBar(),
          body: Column(children: [
            Expanded(
              child: ListView.builder(
                itemCount: c.length,
                itemBuilder: (context, index) => DiscussionCard(c[index]),
              ),
            ),
            DiscussionSnackBar(),
          ]),
        );
      },
      loading: () => const CircularProgressIndicator(),
      orElse: () => SplashScreen.error(),
    );
  }
}
