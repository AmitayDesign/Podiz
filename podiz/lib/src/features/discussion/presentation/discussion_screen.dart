import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/tap_to_unfocus.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/presentation/spoiler/spoiler_indicator.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/palette.dart';

import '../../../common_widgets/empty_screen.dart';
import 'comment/comment_card.dart';
import 'discussion_header.dart';
import 'sheet/comment_sheet.dart';

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

  var isShowingAllComments = false;

  @override
  Widget build(BuildContext context) {
    // update discussion episode
    ref.listen<AsyncValue<PlayingEpisode?>>(
      playerStateChangesProvider,
      (_, episodeValue) => episodeValue.whenData((episode) {
        if (episode != null) {
          Future.microtask(() => setState(() => episodeId = episode.id));
        }
      }),
    );
    return TapToUnfocus(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.darkPurple,
          automaticallyImplyLeading: false,
          title: const BackTextButton(),
        ),
        body: KeyboardVisibilityBuilder(
          builder: (context, isKeyBoardOpen) {
            return Stack(
              children: [
                //TODO too much set states
                //! make a controller for this to only expose comments when needed
                Consumer(
                  builder: (context, ref, _) {
                    // watch player time
                    final commentsValue =
                        ref.watch(commentsStreamProvider(episodeId));
                    final playerTimeValue = ref.watch(playerTimeStreamProvider);
                    const bodyPadding = EdgeInsets.only(
                      top: DiscussionHeader.height,
                      bottom: CommentSheet.height,
                    );

                    //* Loading / Error Widgets
                    return commentsValue.when(
                      loading: () => EmptyScreen.loading(
                        padding: bodyPadding,
                      ),
                      error: (e, _) => EmptyScreen.text(
                        'There was an error displaying the comments.'.hardcoded,
                        padding: bodyPadding,
                      ),
                      data: (comments) {
                        return playerTimeValue.when(
                          loading: () => EmptyScreen.loading(
                            padding: bodyPadding,
                          ),
                          error: (e, _) => EmptyScreen.text(
                            'There was an error displaying the comments.'
                                .hardcoded,
                            padding: bodyPadding,
                          ),
                          data: (playerTime) {
                            if (comments.isEmpty) {
                              EmptyScreen.text(
                                'Comments will be displayed at their respective timestamp...'
                                    .hardcoded,
                                padding: bodyPadding,
                              );
                            }
                            final filteredComments = isShowingAllComments
                                ? comments.reversed.toList()
                                : comments.reversed
                                    .where((comment) =>
                                        comment.time <=
                                        playerTime.position.inMilliseconds)
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

                            //* List of comments
                            return Padding(
                              padding: bodyPadding,
                              child: SpoilerIndicator(
                                reverse: false,
                                enabled: !isShowingAllComments,
                                onAction: (showAll) {
                                  if (showAll) {
                                    setState(() => isShowingAllComments = true);
                                  }
                                },
                                builder: (showingAlert) {
                                  return ListView.builder(
                                    controller: scrollController,
                                    physics: showingAlert
                                        ? const NeverScrollableScrollPhysics()
                                        : const AlwaysScrollableScrollPhysics(),
                                    reverse: true,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: commentsCount,
                                    itemBuilder: (context, i) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: CommentCard(
                                        filteredComments[i],
                                        episodeId: episodeId,
                                        navigate: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                if (isKeyBoardOpen)
                  GestureDetector(
                    onTap: () {
                      ref.read(commentSheetTargetProvider.notifier).state =
                          null;
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(color: Colors.black54),
                  ),
                DiscussionHeader(episodeId),
              ],
            );
          },
        ),
        bottomSheet: const CommentSheet(),
      ),
    );
  }
}
