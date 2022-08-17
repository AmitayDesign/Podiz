import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/widgets/tap_to_unfocus.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';

import 'discussion_bar.dart';
import 'discussion_sheet.dart';

class DiscussionScreen extends ConsumerStatefulWidget {
  final String episodeId;
  const DiscussionScreen(this.episodeId, {Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends ConsumerState<DiscussionScreen> {
  late String episodeId = widget.episodeId;

  @override
  Widget build(BuildContext context) {
    // update discussion episode
    ref.listen<AsyncValue<PlayingEpisode?>>(
      playerStateChangesProvider,
      (_, episodeValue) => episodeValue.whenData((episode) {
        if (episode != null) episodeId = episode.id;
      }),
    );
    // final episodeValue = ref.watch(episodeFutureProvider(episodeId));
    // final commentsValue = ref.watch(commentsStreamProvider(episodeId));
    return TapToUnfocus(
      child: Scaffold(
        appBar: DiscussionBar(widget.episodeId),
        // body: commentsValue.when(
        //   // loading: () => const SizedBox.shrink(), //!
        //   // error: (e, _) => const SizedBox.shrink(), //!
        //   loading: () => const Text('loading'), //!
        //   error: (e, _) => const Text('error'), //!
        //   data: (comments) {
        //     return ListView.builder(
        //       itemCount: comments.length,
        //       itemBuilder: (context, i) =>
        //           DiscussionCard(episodeId, comments[i]),
        //     );
        //   },
        // ),
        bottomSheet: const DiscussionSheet(),
      ),
    );
  }
}
