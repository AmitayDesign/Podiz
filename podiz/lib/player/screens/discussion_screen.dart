import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/widgets/tap_to_unfocus.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';

import 'discussion_bar.dart';
import 'discussion_sheet.dart';

class DiscussionScreen extends ConsumerWidget {
  final String episodeId;
  const DiscussionScreen(this.episodeId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsValue = ref.watch(commentsStreamProvider(episodeId));
    return TapToUnfocus(
      child: Scaffold(
        appBar: DiscussionBar(episodeId),
        body: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) =>
              const ListTile(title: Text('comments loaded')),
        ),
        // commentsValue.when(
        //   // loading: () => const SizedBox.shrink(), //!
        //   // error: (e, _) => const SizedBox.shrink(), //!
        //   loading: () => const Text('loading'), //!
        //   error: (e, _) => const Text('error'), //!
        //   data: (comments) {
        //     return const Text('comments loaded');
        //   },
        // ),
        bottomSheet: const DiscussionSheet(),
      ),
    );
  }
}
