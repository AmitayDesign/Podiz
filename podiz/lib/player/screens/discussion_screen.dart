import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/providers.dart';

import 'discussion_sliver_bar.dart';

class DiscussionScreen extends ConsumerWidget {
  final String episodeId;
  const DiscussionScreen(this.episodeId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsValue = ref.watch(commentsStreamProvider);
    // ref.listen<AsyncValue<PlayingEpisode?>>(
    //   playerStateChangesProvider,
    //   (_, playingEpisodeValue) {
    //     playingEpisodeValue.whenOrNull(data: (playingEpisode) {
    //       if (playingEpisode == null) return;
    //       final playerManager = ref.read(playerManagerProvider);
    //       playerManager.showComments(playingEpisode.initialPosition);
    //     });
    //   },
    // );
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DiscussionSliverBar(episodeId),
          SliverToBoxAdapter(
            child: commentsValue.when(
              // loading: () => const SizedBox.shrink(), //!
              // error: (e, _) => const SizedBox.shrink(), //!
              loading: () => const Text('loading'), //!
              error: (e, _) => const Text('error'), //!
              data: (comments) {
                return const Text('comments loaded');
              },
            ),
          ),
        ],
      ),
      // bottomSheet: DiscussionSheet(episodeId),
    );
  }
}
