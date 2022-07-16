import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/player/components/discussionAppBar.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/player/components/discussionSnackBar.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class DiscussionPage extends ConsumerStatefulWidget {
  Podcast podcast;
  DiscussionPage(this.podcast, {Key? key}) : super(key: key);
  static const route = '/discussion';

  @override
  ConsumerState<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends ConsumerState<DiscussionPage> {
  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsStreamProvider);
    return comments.maybeWhen(
      data: (comments) => Scaffold(
        appBar: DiscussionAppBar(widget.podcast),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) => DiscussionCard(comments[index]),
            ),
          ),
          DiscussionSnackBar(),
        ]),
      ),
      loading: () => const CircularProgressIndicator(),
      orElse: () => SplashScreen.error(),

    );
  }
}
