import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/widgets/tap_to_unfocus.dart';
import 'package:podiz/player/screens/comment_card.dart';
import 'package:podiz/player/screens/discussion_header.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/palette.dart';

import 'discussion_sheet.dart';

class DiscussionScreen extends ConsumerStatefulWidget {
  final String episodeId;
  const DiscussionScreen(this.episodeId, {Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends ConsumerState<DiscussionScreen> {
  late String episodeId = widget.episodeId;

  final scrollController = ScrollController();
  int commentsCount = 0;

  @override
  Widget build(BuildContext context) {
    // update discussion episode
    ref.listen<AsyncValue<PlayingEpisode?>>(
      playerStateChangesProvider,
      (_, episodeValue) => episodeValue.whenData((episode) {
        if (episode != null) episodeId = episode.id;
      }),
    );
    return TapToUnfocus(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.darkPurple,
          automaticallyImplyLeading: false,
          title: const BackTextButton(),
        ),
        body: Column(
          children: [
            DiscussionHeader(episodeId),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  // watch player time
                  final commentsValue =
                      ref.watch(commentsStreamProvider(episodeId));
                  final playerTimeValue = ref.watch(playerTimeStreamProvider);
                  return commentsValue.when(
                    loading: () => const EmptyDiscussionText(),
                    error: (e, _) => EmptyDiscussionText(
                      text: 'Error loading comments'.hardcoded,
                    ),
                    data: (comments) {
                      return playerTimeValue.when(
                        loading: () => const EmptyDiscussionText(),
                        error: (e, _) => EmptyDiscussionText(
                          text: 'Error playing this episode'.hardcoded,
                        ),
                        data: (playerTime) {
                          if (comments.isEmpty) const EmptyDiscussionText();
                          final filteredComments = comments.reversed
                              .where((comment) =>
                                  comment.time ~/ 1000 <= playerTime.position)
                              .toList();
                          if (commentsCount != 0 &&
                              commentsCount != filteredComments.length &&
                              scrollController.hasClients &&
                              scrollController.offset < 100) {
                            Future.microtask(() => scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.ease,
                                ));
                          }
                          commentsCount = filteredComments.length;
                          return ListView.builder(
                            controller: scrollController,
                            reverse: true,
                            padding: const EdgeInsets.only(
                              bottom: DiscussionSheet.height,
                            ),
                            itemCount: filteredComments.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CommentCard(
                                filteredComments[i],
                                episodeId: episodeId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomSheet: const DiscussionSheet(),
      ),
    );
  }
}

//TODO no comments yet widget
class EmptyDiscussionText extends StatelessWidget {
  final String? text;
  const EmptyDiscussionText({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(
        bottom: DiscussionSheet.height,
      ).add(const EdgeInsets.symmetric(horizontal: 16)),
      child: Text(
        text ??
            'Comments will be displayed at their respective timestamp...'
                .hardcoded,
        textAlign: TextAlign.center,
      ),
    );
  }
}
